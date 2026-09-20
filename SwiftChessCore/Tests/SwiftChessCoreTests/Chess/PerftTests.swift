import Testing
@testable import SwiftChessCore

extension Tag {
    @Tag static var slowPerft: Self
}

@Suite(.serialized)
struct PerftTests {

    @Test func testPerft_startPosition_depths1to4() async throws {
        let position = try PositionFactory.startingPosition()
        #expect(await perft(position, depth: 1) == 20)
        #expect(await perft(position, depth: 2) == 400)
        #expect(await perft(position, depth: 3) == 8902)
        #expect(await perft(position, depth: 4) == 197281)
    }

    @Test(.tags(.slowPerft), .disabled("slow at this generator's current per-move cost; run manually to validate Board/Position rewrites (Phase 3)"))
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

    @Test(.tags(.slowPerft), .disabled("slow at this generator's current per-move cost; run manually to validate castling-rights regressions"))
    func testPerft_kiwipete_depth4() async throws {
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

    @Test(.tags(.slowPerft), .disabled("slow at this generator's current per-move cost; run manually to validate Board/Position rewrites (Phase 3)"))
    func testPerft_position3_depth5() async throws {
        let position = try #require(PositionFactory.loadPosition("8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1"))
        #expect(await perft(position, depth: 5) == 674624)
    }

    @Test func testPerft_position4_depths1to3() async throws {
        // CPW "Position 4": asymmetric (white about to promote-with-capture, black to castle) —
        // catches bugs that a color-symmetric position could hide on only one side's code path.
        let position = try #require(PositionFactory.loadPosition("r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1"))
        #expect(await perft(position, depth: 1) == 6)
        #expect(await perft(position, depth: 2) == 264)
        #expect(await perft(position, depth: 3) == 9467)
    }

    @Test func testPerft_position5_depths1to3() async throws {
        // CPW "Position 5": knight giving check adjacent to the king with a pawn one square from
        // promoting — exercises pin/discovered-check and promotion interacting together.
        let position = try #require(PositionFactory.loadPosition("rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8"))
        #expect(await perft(position, depth: 1) == 44)
        #expect(await perft(position, depth: 2) == 1486)
        #expect(await perft(position, depth: 3) == 62379)
    }

    @Test func testPerft_position6_depths1to3() async throws {
        // CPW "Position 6": no special-rule interactions — a pure raw-branching-factor regression check.
        let position = try #require(PositionFactory.loadPosition("r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10"))
        #expect(await perft(position, depth: 1) == 46)
        #expect(await perft(position, depth: 2) == 2079)
        #expect(await perft(position, depth: 3) == 89890)
    }

    @Test func testPerftDivide_matchesPerftTotal() async throws {
        // `divide` exists to localize a future depth-4+ regression to a single root move instead of
        // only knowing the aggregate total is wrong. This test just proves divide and perft agree,
        // since divide has no separate published reference table to compare against.
        let position = try #require(PositionFactory.loadPosition("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1"))
        let breakdown = await perftDivide(position, depth: 3)
        #expect(breakdown.values.reduce(0, +) == 97862)
        #expect(breakdown.count == 48)
    }

    /// Breaks perft(depth) down by root move, for isolating which root move's subtree diverges
    /// from a reference value — the standard chess-programming-wiki debugging technique.
    private func perftDivide(_ position: Position, depth: Int) async -> [String: Int] {
        guard depth > 0 else { return [:] }
        let rootMoves = Self.legalMovesWithResultingPositions(at: position)
        return await withTaskGroup(of: (String, Int).self) { group in
            for (move, childPosition) in rootMoves {
                group.addTask {
                    var cache: [Self.PerftKey: Int] = [:]
                    let count = depth == 1 ? 1 : Self.perftMemoized(childPosition, depth: depth - 1, cache: &cache)
                    return (move.id, count)
                }
            }
            var result: [String: Int] = [:]
            for await (id, count) in group { result[id] = count }
            return result
        }
    }

    private func perft(_ position: Position, depth: Int) async -> Int {
        guard depth > 0 else { return 1 }
        let moves = Self.legalMovesWithResultingPositions(at: position)
        if depth == 1 { return moves.count }

        return await withTaskGroup(of: Int.self) { group in
            for (_, childPosition) in moves {
                group.addTask {
                    var cache: [Self.PerftKey: Int] = [:]
                    return Self.perftMemoized(childPosition, depth: depth - 1, cache: &cache)
                }
            }
            var total = 0
            for await value in group { total += value }
            return total
        }
    }

    private struct PerftKey: Hashable {
        let hash: Int
        let depth: Int
    }


    private static func perftMemoized(_ position: Position, depth: Int, cache: inout [PerftKey: Int]) -> Int {
        guard depth > 0 else { return 1 }
        if depth == 1 { return legalMovesWithResultingPositions(at: position).count }

        let key = PerftKey(hash: position.hash, depth: depth)
        if let cached = cache[key] { return cached }

        var total = 0
        for (_, childPosition) in legalMovesWithResultingPositions(at: position) {
            total += perftMemoized(childPosition, depth: depth - 1, cache: &cache)
        }
        cache[key] = total
        return total
    }

    private static func legalMovesWithResultingPositions(at position: Position) -> [(move: Move, position: Position)] {
        let validator = MoveValidator(position)
        return position.figures
            .filter { $0.color == position.colorToMove }
            .flatMap { $0.getPossibleMoves() }
            .flatMap(expandPromotions)
            .compactMap { move in validator.resultingPositionIfLegal(move).map { (move, $0) } }
    }

    private static func expandPromotions(_ move: Move) -> [Move] {
        guard move.type == .promotion else { return [move] }
        return PromotionPiece.allCases.map { Move(move, promoteTo: $0) }
    }
}
