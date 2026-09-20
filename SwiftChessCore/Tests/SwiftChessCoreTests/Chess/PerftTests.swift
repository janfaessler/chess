import Testing
@testable import SwiftChessCore

// Reference node counts are the standard, cross-engine-verified values from the
// chess-programming-wiki perft page. Any correct move generator must reproduce them exactly.
//
// `.serialized`: Swift Testing runs `@Test` functions in this suite concurrently with each
// other by default. `perft` below fans work out across a `TaskGroup` internally, so letting the
// *test runner* also run multiple perft tests at once means several independent TaskGroups (each
// spawning dozens of tasks) fight over the same cooperative thread pool at once. Measured effect:
// oversubscribing this way made every test slower than the *unoptimized*, non-concurrent baseline
// (all four ran together in ~28s unoptimized vs. 100+ seconds each with two uncoordinated layers
// of parallelism). Serializing the suite removes that layer of contention — each perft call still
// gets the full thread pool to itself, it just doesn't have to share it with sibling tests.
@Suite(.serialized)
struct PerftTests {

    @Test func testPerft_startPosition_depths1to4() async throws {
        let position = try PositionFactory.startingPosition()
        #expect(await perft(position, depth: 1) == 20)
        #expect(await perft(position, depth: 2) == 400)
        #expect(await perft(position, depth: 3) == 8902)
        #expect(await perft(position, depth: 4) == 197281)
    }

    @Test(.disabled("slow at this generator's current per-move cost; run manually to validate Board/Position rewrites (Phase 3)"))
    func testPerft_startPosition_depth5() async throws {
        let position = try PositionFactory.startingPosition()
        #expect(await perft(position, depth: 5) == 4865609)
    }

    @Test func testPerft_kiwipete_depths1to3() async throws {
        // Kiwipete: exercises castling, en passant, and promotions together.
        let position = try #require(PositionFactory.loadPosition("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1"))
        #expect(await perft(position, depth: 1) == 48)
        #expect(await perft(position, depth: 2) == 2039)
        #expect(await perft(position, depth: 3) == 97862)
    }

    @Test(.disabled("slow at this generator's current per-move cost; run manually to validate castling-rights regressions"))
    func testPerft_kiwipete_depth4() async throws {
        // Regression for a bug where capturing a rook away from its home square (e.g. after
        // it had already moved) revoked BOTH of that color's castling rights instead of just
        // the one matching the file it happened to be captured on. See CastlingRulesTests
        // for the isolated single-move reproduction; this depth reliably surfaced it because
        // it requires "rook moves off its home file, then gets captured elsewhere on that file"
        // — a three-ply interaction unit tests targeting one FIDE rule at a time do not reach.
        let position = try #require(PositionFactory.loadPosition("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1"))
        #expect(await perft(position, depth: 4) == 4074224)
    }

    @Test func testPerft_position3_depths1to4() async throws {
        // CPW "Position 3": exercises pins and discovered checks at shallow depth.
        let position = try #require(PositionFactory.loadPosition("8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1"))
        #expect(await perft(position, depth: 1) == 14)
        #expect(await perft(position, depth: 2) == 191)
        #expect(await perft(position, depth: 3) == 2812)
        #expect(await perft(position, depth: 4) == 43238)
    }

    @Test(.disabled("slow at this generator's current per-move cost; run manually to validate Board/Position rewrites (Phase 3)"))
    func testPerft_position3_depth5() async throws {
        let position = try #require(PositionFactory.loadPosition("8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1"))
        #expect(await perft(position, depth: 5) == 674624)
    }

    // Root-level branches are independent subtrees, so they're fanned out across the cooperative
    // thread pool with a TaskGroup rather than walked one at a time — safe to do now that the
    // suite is `.serialized`, so this is the only perft call using the pool at any moment.
    // Everything below the root recurses serially through `perftMemoized`, which still drives move
    // generation and legality entirely through the production `MoveValidator`/`Position.applying`
    // API — the only thing added is a node-count cache keyed by (position hash, remaining depth).
    // Many different move orders transpose into the same board + castling-rights + en-passant
    // state, and `position.hash` already excludes halfmove/fullmove clocks (see
    // Position.computeHash), so it's exactly the right key for coalescing those transpositions
    // instead of re-walking them. The cache is created fresh per top-level call (not shared across
    // tests via a static singleton) since unrelated FENs have no transpositions in common and
    // sharing would only add actor contention for no benefit.
    private func perft(_ position: Position, depth: Int) async -> Int {
        guard depth > 0 else { return 1 }
        let moves = Self.legalMoves(at: position)
        if depth == 1 { return moves.count }

        let cache = PerftCache()
        return await withTaskGroup(of: Int.self) { group in
            for move in moves {
                group.addTask {
                    await Self.perftMemoized(position.applying(move), depth: depth - 1, cache: cache)
                }
            }
            var total = 0
            for await value in group { total += value }
            return total
        }
    }

    private static func perftMemoized(_ position: Position, depth: Int, cache: PerftCache) async -> Int {
        guard depth > 0 else { return 1 }
        // Leaf-depth calls (depth == 1) are by far the most frequent — the branching factor
        // means there are orders of magnitude more of them than of any other depth — and a move
        // count is already as cheap as a cache lookup would be. Routing them through the
        // actor-guarded cache anyway would spend an actor hop on the single most common call for
        // no benefit — measured as a regression on the low-branching-factor Position 3 case
        // (~2.2s to ~7.2s) before this guard was added. Caching only pays off from depth 2 up,
        // where the subtree being memoized is actually expensive to redo.
        if depth == 1 { return legalMoves(at: position).count }

        let key = PerftCache.Key(hash: position.hash, depth: depth)
        if let cached = await cache.get(key) { return cached }

        var total = 0
        for move in legalMoves(at: position) {
            total += await perftMemoized(position.applying(move), depth: depth - 1, cache: cache)
        }
        await cache.set(key, total)
        return total
    }

    private static func legalMoves(at position: Position) -> [Move] {
        let validator = MoveValidator(position)
        return position.figures
            .filter { $0.color == position.colorToMove }
            .flatMap { $0.getPossibleMoves() }
            .filter { validator.isLegalMove($0) }
    }
}

/// Node-count cache for a single `PerftTests.perft` call tree, keyed by (position hash,
/// remaining depth) and guarded by an actor since root-level branches populate it concurrently
/// from a `TaskGroup`. One instance is created per top-level `perft` call — see the comment there.
private actor PerftCache {
    struct Key: Hashable {
        let hash: Int
        let depth: Int
    }

    private var table: [Key: Int] = [:]

    func get(_ key: Key) -> Int? { table[key] }
    func set(_ key: Key, _ value: Int) { table[key] = value }
}
