import Testing
@testable import SwiftChessCore

struct SlidingMovesTests {

    @Test func testAlong_bishopFromCenter_staysOnBoard() throws {
        let fen = "8/8/8/8/4B3/8/8/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let bishop = try #require(position.get(atRow: 4, atFile: 5))
        let rays = [(-1, -1), (+1, +1), (-1, +1), (+1, -1)].map { (row: $0.0, file: $0.1) }
        let moves = SlidingMoves.along(rays: rays, piece: bishop)
        #expect(!moves.isEmpty)
        #expect(moves.allSatisfy { (1...8).contains($0.row) && (1...8).contains($0.file) })
    }

    @Test func testAlong_rookGoingEast_reachesEdge() throws {
        let fen = "8/8/8/8/4R3/8/8/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let rook = try #require(position.get(atRow: 4, atFile: 5))
        let moves = SlidingMoves.along(rays: [(row: 0, file: +1)], piece: rook)
        #expect(moves.count == 3)
        #expect(moves.last?.file == 8)
    }

    @Test func testAlong_rookGoingWest_reachesEdge() throws {
        let fen = "8/8/8/8/4R3/8/8/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let rook = try #require(position.get(atRow: 4, atFile: 5))
        let moves = SlidingMoves.along(rays: [(row: 0, file: -1)], piece: rook)
        #expect(moves.count == 4)
        #expect(moves.last?.file == 1)
    }

    @Test func testAlong_cornerRook_hasLimitedMoves() throws {
        let fen = "R7/8/8/8/8/8/8/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let rook = try #require(position.get(atRow: 8, atFile: 1))
        let allRays = [(0, +1), (0, -1), (+1, 0), (-1, 0)].map { (row: $0.0, file: $0.1) }
        let moves = SlidingMoves.along(rays: allRays, piece: rook)
        #expect(moves.allSatisfy { (1...8).contains($0.row) && (1...8).contains($0.file) })
        #expect(moves.count == 14)
    }

    @Test func testAlong_queenFromCenter_generatesAllDirections() throws {
        let fen = "8/8/8/4Q3/8/8/8/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let queen = try #require(position.get(atRow: 5, atFile: 5))
        let allRays = [(-1,-1),(0,-1),(+1,-1),(-1,0),(+1,0),(-1,+1),(0,+1),(+1,+1)].map { (row: $0.0, file: $0.1) }
        let moves = SlidingMoves.along(rays: allRays, piece: queen)
        #expect(moves.count > 0)
        #expect(moves.allSatisfy { (1...8).contains($0.row) && (1...8).contains($0.file) })
    }

    @Test func testAlong_bishopOnCornerA1_onlyNERayAvailable() throws {
        let bishop = PieceFactory.create("a1", type: .bishop, color: .white)!
        let allDiagonals = [(-1,-1),(+1,+1),(-1,+1),(+1,-1)].map { (row: $0.0, file: $0.1) }
        let moves = SlidingMoves.along(rays: allDiagonals, piece: bishop)
        #expect(moves.count == 7, "bishop on a1 has only the NE ray (b2–h8), 7 squares")
        #expect(moves.allSatisfy { $0.row == $0.file }, "all reachable squares lie on the main a1–h8 diagonal")
    }

    @Test func testAlong_rookOnCornerH1_hasLimitedMoves() throws {
        let rook = PieceFactory.create("h1", type: .rook, color: .white)!
        let allRays = [(0,+1),(0,-1),(+1,0),(-1,0)].map { (row: $0.0, file: $0.1) }
        let moves = SlidingMoves.along(rays: allRays, piece: rook)
        #expect(moves.count == 14, "rook on h1 has 7 west squares + 7 north squares = 14")
        #expect(moves.allSatisfy { (1...8).contains($0.row) && (1...8).contains($0.file) })
    }

    @Test func testAlong_bishopOnCornerH8_onlySWRayAvailable() throws {
        let bishop = PieceFactory.create("h8", type: .bishop, color: .white)!
        let allDiagonals = [(-1,-1),(+1,+1),(-1,+1),(+1,-1)].map { (row: $0.0, file: $0.1) }
        let moves = SlidingMoves.along(rays: allDiagonals, piece: bishop)
        #expect(moves.count == 7, "bishop on h8 has only the SW ray (g7–a1), 7 squares")
        #expect(moves.allSatisfy { $0.row == $0.file }, "all reachable squares lie on the main a1–h8 diagonal")
    }
}
