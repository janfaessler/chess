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
}
