import Testing
@testable import SwiftChessCore

final class RawMovesTests: ChessTestBase {

    @Test func testEquality_underpromotionsAreDistinct() throws {
        let pawn = PieceFactory.create("e7", type: .pawn, color: .white)!
        let toQueen = try #require(pawn.createMove("e8", type: .promotion, promoteTo: .queen))
        let toKnight = try #require(pawn.createMove("e8", type: .promotion, promoteTo: .knight))
        #expect(toQueen != toKnight, "e8=Q and e8=N must not compare equal")
    }

    @Test func testIdentity_equalMovesShareId() throws {
        let pawn = PieceFactory.create("e7", type: .pawn, color: .white)!
        let a = try #require(pawn.createMove("e8", type: .promotion, promoteTo: .knight))
        let b = try #require(pawn.createMove("e8", type: .promotion, promoteTo: .knight))
        let queen = try #require(pawn.createMove("e8", type: .promotion, promoteTo: .queen))
        #expect(a == b)
        #expect(a.id == b.id, "structurally equal moves must share an id")
        #expect(a.id != queen.id, "moves that differ must have different ids")
    }

    @Test func testSlidingMoves_countMatches() throws {
        let rook = PieceFactory.create("d4", type: .rook, color: .white)!
        let bishop = PieceFactory.create("d4", type: .bishop, color: .white)!
        let queen = PieceFactory.create("d4", type: .queen, color: .white)!

        let rookMoves = rook.getPossibleMoves()
        let bishopMoves = bishop.getPossibleMoves()
        let queenMoves = queen.getPossibleMoves()

        #expect(rookMoves.count == 14, "rook on d4 has 7 rank + 7 file pseudo-moves")
        #expect(bishopMoves.count == 13, "bishop on d4 has 13 diagonal pseudo-moves")
        #expect(queenMoves.count == 27, "queen on d4 has rook + bishop pseudo-moves")

        for moves in [rookMoves, bishopMoves, queenMoves] {
            #expect(!moves.contains { $0.row == 4 && $0.file == 4 }, "must not include the origin square")
            #expect(moves.allSatisfy { 1...8 ~= $0.row && 1...8 ~= $0.file }, "all targets on the board")
            #expect(Set(moves.map { $0.square }).count == moves.count, "no duplicate target squares")
        }

        #expect(bishopMoves.contains { $0.square == Square(row: 8, file: 8) }, "bishop reaches h8")
        #expect(bishopMoves.contains { $0.square == Square(row: 1, file: 1) }, "bishop reaches a1")
        #expect(rookMoves.contains { $0.square == Square(row: 4, file: 8) }, "rook reaches h4")
        #expect(rookMoves.contains { $0.square == Square(row: 1, file: 4) }, "rook reaches d1")
    }

    @Test func testSimplePawnCapture() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "d7", to: "d5", type: .pawn, color: .black, moveType: .double)
        try captureAndAssert("e4", to: "d5", type: .pawn, color: .white)
        try assertMoves(["e4", "d5", "exd5"])
    }

    @Test func testEnPassantLeft() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "a7", to: "a6", type: .pawn, color: .black)
        try moveAndAssert(from: "e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert(from: "d7", to: "d5", type: .pawn, color: .black, moveType: .double)
        try captureAndAssert("e5", to: "d6", type: .pawn, color: .white)
        try assertMoves(["e4", "a6", "e5", "d5", "exd6"])
    }

    @Test func testEnPassanRight() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "a7", to: "a6", type: .pawn, color: .black)
        try moveAndAssert(from: "e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert(from: "f7", to: "f5", type: .pawn, color: .black, moveType: .double)
        try captureAndAssert("e5", to: "f6", type: .pawn, color: .white)
        try assertMoves(["e4", "a6", "e5", "f5", "exf6"])
    }

    @Test func testEnPassantToPromotion() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "a7", to: "a6", type: .pawn, color: .black)
        try moveAndAssert(from: "e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert(from: "d7", to: "d5", type: .pawn, color: .black, moveType: .double)
        try captureAndAssert("e5", to: "d6", type: .pawn, color: .white)
        try moveAndAssert(from: "b7", to: "b5", type: .pawn, color: .black, moveType: .double)
        try captureAndAssert("d6", to: "e7", type: .pawn, color: .white)
        try moveAndAssert(from: "c7", to: "c5", type: .pawn, color: .black, moveType: .double)
        try captureAndAssertPromotion("e7", to: "d8", type: .pawn, color: .white)
        try assertMoves(["e4", "a6", "e5", "d5", "exd6", "b5", "dxe7", "c5", "exd8=Q+"])
    }

    @Test func testShortCastle() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "f8", to: "c5", type: .bishop, color: .black)
        try moveAndAssert(from: "g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert(from: "g8", to: "f6", type: .knight, color: .black)
        try moveAndAssert(from: "e1", to: "g1", type: .king, color: .white, moveType: .castle)
        try moveAndAssert(from: "e8", to: "g8", type: .king, color: .black, moveType: .castle)
        try assertMoves(["e4", "e5", "Bc4", "Bc5", "Nf3", "Nf6", "O-O", "O-O"])
    }

    @Test func testLongCastle() throws {
        try moveAndAssert(from: "b2", to: "b3", type: .pawn, color: .white)
        try moveAndAssert(from: "b7", to: "b6", type: .pawn, color: .black)
        try moveAndAssert(from: "c1", to: "b2", type: .bishop, color: .white)
        try moveAndAssert(from: "c8", to: "b7", type: .bishop, color: .black)
        try moveAndAssert(from: "b1", to: "c3", type: .knight, color: .white)
        try moveAndAssert(from: "b8", to: "c6", type: .knight, color: .black)
        try moveAndAssert(from: "e2", to: "e3", type: .pawn, color: .white)
        try moveAndAssert(from: "e7", to: "e6", type: .pawn, color: .black)
        try moveAndAssert(from: "d1", to: "e2", type: .queen, color: .white)
        try moveAndAssert(from: "d8", to: "e7", type: .queen, color: .black)
        try moveAndAssert(from: "e1", to: "c1", type: .king, color: .white, moveType: .castle)
        try moveAndAssert(from: "e8", to: "c8", type: .king, color: .black, moveType: .castle)
        try assertMoves(["b3", "b6", "Bb2", "Bb7", "Nc3", "Nc6", "e3", "e6", "Qe2", "Qe7", "O-O-O", "O-O-O"])
    }

    @Test func testCastleAttemptStartInCheck() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "f2", to: "f3", type: .pawn, color: .white)
        try moveAndAssert(from: "f7", to: "f5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "d7", to: "d6", type: .pawn, color: .black)
        try moveAndAssert(from: "g1", to: "h3", type: .knight, color: .white)
        try moveAndAssert(from: "d8", to: "h4", type: .queen, color: .black)
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .castle)
        try assertMoves(["e4", "e5", "f3", "f5", "Bc4", "d6", "Nh3", "Qh4+"])
    }

    @Test func testCastleAttemptMiddleInCheck() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert(from: "d7", to: "d6", type: .pawn, color: .black)
        try moveAndAssert(from: "h2", to: "h3", type: .pawn, color: .white)
        try moveAndAssert(from: "c8", to: "e6", type: .bishop, color: .black)
        try moveAndAssert(from: "b1", to: "a3", type: .knight, color: .white)
        try moveAndAssert(from: "f7", to: "f6", type: .pawn, color: .black)
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try captureAndAssert("e6", to: "c4", type: .bishop, color: .black)
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .castle)
        try assertMoves(["e4", "e5", "Nf3", "d6", "h3", "Be6", "Na3", "f6", "Bc4", "Bxc4"])
    }

    @Test func testCastleAttemptTargetInCheck() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "f2", to: "f3", type: .pawn, color: .white)
        try moveAndAssert(from: "f8", to: "c5", type: .bishop, color: .black)
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "d7", to: "d6", type: .pawn, color: .black)
        try moveAndAssert(from: "g1", to: "e2", type: .knight, color: .white)
        try moveAndAssert(from: "f7", to: "f6", type: .pawn, color: .black)
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .castle)
        try assertMoves(["e4", "e5", "f3", "Bc5", "Bc4", "d6", "Ne2", "f6"])
    }

    @Test func testCastleKingsideBlockedByKnight() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "a7", to: "a6", type: .pawn, color: .black)
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .castle)
        try assertMoves(["e4", "e5", "Bc4", "a6"])
    }

    @Test func testCastleKingsideBlockedByBishop() throws {
        try moveAndAssert(from: "g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert(from: "a7", to: "a6", type: .pawn, color: .black)
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .castle)
        try assertMoves(["Nf3", "a6"])
    }

    @Test func testCastleQueensideBlockedByQueen() throws {
        try moveAndAssert(from: "b2", to: "b3", type: .pawn, color: .white)
        try moveAndAssert(from: "a7", to: "a6", type: .pawn, color: .black)
        try moveAndAssert(from: "c1", to: "b2", type: .bishop, color: .white)
        try moveAndAssert(from: "b7", to: "b6", type: .pawn, color: .black)
        try moveAndAssert(from: "b1", to: "c3", type: .knight, color: .white)
        try moveAndAssert(from: "c7", to: "c6", type: .pawn, color: .black)
        try moveAndAssertError("e1", to: "c1", type: .king, color: .white, moveType: .castle)
        try assertMoves(["b3", "a6", "Bb2", "b6", "Nc3", "c6"])
    }

    @Test func testCastleWithoutRook() throws {
        try moveAndAssert(from: "g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert(from: "b7", to: "b6", type: .pawn, color: .black)
        try moveAndAssert(from: "g2", to: "g3", type: .pawn, color: .white)
        try moveAndAssert(from: "c8", to: "b7", type: .bishop, color: .black)
        try moveAndAssert(from: "f1", to: "g2", type: .bishop, color: .white)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .double)
        try captureAndAssert("f3", to: "e5", type: .knight, color: .white)
        try captureAndAssert("b7", to: "g2", type: .bishop, color: .black)
        try captureAndAssert("e5", to: "f7", type: .knight, color: .white)
        try captureAndAssert("g2", to: "h1", type: .bishop, color: .black)
        try captureAndAssert("f7", to: "d8", type: .knight, color: .white)
        try captureAndAssert("e8", to: "d8", type: .king, color: .black)
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .castle)
        try assertMoves(["Nf3", "b6", "g3", "Bb7", "Bg2", "e5", "Nxe5", "Bxg2", "Nxf7", "Bxh1", "Nxd8", "Kxd8"])
    }

    @Test func testSimpleCastleWithTryingWrongMoves() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssertError("f1", to: "c5", type: .bishop, color: .white)
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "f8", to: "b4", type: .bishop, color: .black)
        try moveAndAssertError("d2", to: "d3", type: .pawn, color: .white)
        try moveAndAssertError("d2", to: "d4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "c2", to: "c3", type: .pawn, color: .white)
        try moveAndAssert(from: "g8", to: "f6", type: .knight, color: .black)
        try moveAndAssert(from: "g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert(from: "e8", to: "g8", type: .king, color: .black, moveType: .castle)
        try captureAndAssert("c3", to: "b4", type: .pawn, color: .white)
        try moveAndAssert(from: "f8", to: "e8", type: .rook, color: .black)
        try moveAndAssert(from: "e1", to: "g1", type: .king, color: .white, moveType: .castle)
        try moveAndAssert(from: "g8", to: "h8", type: .king, color: .black)
        try moveAndAssert(from: "g1", to: "h1", type: .king, color: .white)
        #expect(PieceFactory.create("h8", type: .king, color: .black)!.createMove(8, 9) == nil)
        try assertMoves(["e4", "e5", "Bc4", "Bb4", "c3", "Nf6", "Nf3", "O-O", "cxb4", "Re8", "O-O", "Kh8", "Kh1"])
    }

    @Test func testRowIntersection() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "e7", to: "e5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "d8", to: "h4", type: .queen, color: .black)
        try moveAndAssert(from: "a2", to: "a3", type: .pawn, color: .white)
        try captureAndAssertError("h4", to: "c4", type: .queen, color: .black)
        try captureAndAssert("h4", to: "e4", type: .queen, color: .black)
        try assertMoves(["e4", "e5", "Bc4", "Qh4", "a3", "Qxe4+"])
    }

    @Test func testCheckMate() throws {
        try moveAndAssert(from: "e2", to: "e4", type: .pawn, color: .white, moveType: .double)
        try moveAndAssert(from: "f7", to: "f5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert(from: "e7", to: "e6", type: .pawn, color: .black)
        try moveAndAssert(from: "h2", to: "h3", type: .pawn, color: .white)
        try moveAndAssert(from: "g7", to: "g5", type: .pawn, color: .black, moveType: .double)
        try moveAndAssert(from: "d1", to: "h5", type: .queen, color: .white)

        let king = PieceFactory.create("e8", type: .king, color: .black)!
        try assertPossibleMoves(forFigure: king, moves: [king.createMove("e7")!])

        try moveAndAssert(from: "e8", to: "e7", type: .king, color: .black)
        try moveAndAssert(from: "e4", to: "e5", type: .pawn, color: .white)

        try assertPossibleMoves(forFigure: PieceFactory.create("e7", type: .king, color: .black)!, moves: [])

        try moveAndAssert(from: "a7", to: "a6", type: .pawn, color: .black)
        try moveAndAssert(from: "d2", to: "d3", type: .pawn, color: .white)
        try moveAndAssert(from: "b7", to: "b5", type: .pawn, color: .black, moveType: .double)
        try captureAndAssert("c1", to: "g5", type: .bishop, color: .white)
        try moveAndAssert(from: "g8", to: "f6", type: .knight, color: .black)
        try captureAndAssert("g5", to: "f6", type: .bishop, color: .white)
        try assertMoves(["e4", "f5", "Bc4", "e6", "h3", "g5", "Qh5+", "Ke7", "e5", "a6", "d3", "b5", "Bxg5+", "Nf6", "Bxf6#"])
    }

    @Test func testPawnCannotCaptureOwnPiece() throws {
        loadFen("4k3/8/8/3B4/4P3/8/8/4K3 w - - 0 1")
        let testee = try #require(testee)

        let pawn = try #require(testee.figures.first { $0.equals(PieceFactory.create("e4", type: .pawn, color: .white)!) })
        let canCaptureOwnBishop = testee.getPossibleMoves(forPiece: pawn).contains { $0.square == Square(row: 5, file: 4) }
        #expect(!canCaptureOwnBishop, "white pawn on e4 must not be able to capture its own bishop on d5")

        try moveAndAssertError(PieceFactory.create("e4", type: .pawn, color: .white)!.createMove("d5", type: .normal, promoteTo: .queen)!)
    }

    @Test func testPawnCanStillCaptureEnemyPiece() throws {
        loadFen("4k3/8/8/3b4/4P3/8/8/4K3 w - - 0 1")
        let testee = try #require(testee)

        let pawn = try #require(testee.figures.first { $0.equals(PieceFactory.create("e4", type: .pawn, color: .white)!) })
        let canCaptureEnemyBishop = testee.getPossibleMoves(forPiece: pawn).contains { $0.square == Square(row: 5, file: 4) }
        #expect(canCaptureEnemyBishop, "white pawn on e4 must be able to capture the black bishop on d5")
    }

    @Test func testStraightPawnPromotion() throws {
        loadFen("4k3/P7/8/8/8/8/8/4K3 w - - 0 1")
        let testee = try #require(testee)

        let pawn = try #require(testee.figures.first { $0.equals(PieceFactory.create("a7", type: .pawn, color: .white)!) })
        let canPushToPromote = testee.getPossibleMoves(forPiece: pawn).contains { $0.square == Square(row: 8, file: 1) }
        #expect(canPushToPromote, "white pawn on a7 must be able to push to a8 to promote")

        let move = try #require(PieceFactory.create("a7", type: .pawn, color: .white)!.createMove("a8", type: .promotion, promoteTo: .queen))
        try testee.move(move)

        assertFigureNotExists(PieceFactory.create("a7", type: .pawn, color: .white)!)
        assertFigureExists(PieceFactory.create("a8", type: .queen, color: .white)!)
    }

    @Test func testKingCannotMoveIntoCheck() throws {
        loadFen("k7/8/8/8/8/8/8/4K2r w - - 0 1")
        try moveAndAssertError("e1", to: "f1", type: .king, color: .white)
        try moveAndAssertError("e1", to: "d1", type: .king, color: .white)
    }

    @Test func testPinnedPieceCannotMove() throws {
        loadFen("k3r3/8/8/8/4B3/8/8/4K3 w - - 0 1")
        let testee = try #require(testee)
        let bishop = try #require(testee.figures.first { $0.equals(PieceFactory.create("e4", type: .bishop, color: .white)!) })
        #expect(testee.getPossibleMoves(forPiece: bishop).isEmpty, "pinned bishop must have no legal moves")
    }

    @Test func testDiscoveredCheck_moveNotationIncludesCheck() throws {
        loadFen("4k3/8/8/4B3/8/8/8/4RK2 w - - 0 1")
        try moveAndAssert(notation: "Bd6", toField: "d6", type: .bishop, color: .white)
        #expect(moveLogNotations().last?.contains("+") == true, "Bd6 should give discovered check via rook on e-file")
    }
}
