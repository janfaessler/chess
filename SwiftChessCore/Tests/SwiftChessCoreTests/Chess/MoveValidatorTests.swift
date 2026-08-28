import Testing
@testable import SwiftChessCore

struct MoveValidatorTests {

    @Test func testIsLegalMove_validPawnAdvance_returnsTrue() throws {
        let position = try PositionFactory.startingPosition()
        let validator = MoveValidator(position)
        let pawn = try #require(position.get(atRow: 2, atFile: 5))
        let move = try #require(pawn.createMove("e4", type: .double, promoteTo: .queen))
        #expect(validator.isLegalMove(move))
    }

    @Test func testIsLegalMove_moveExposingKing_returnsFalse() throws {
        let fen = "4r3/8/8/8/8/8/4B3/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let validator = MoveValidator(position)
        let bishop = try #require(position.get(atRow: 2, atFile: 5))
        let move = try #require(bishop.createMove("d3", type: .normal, promoteTo: .queen))
        #expect(!validator.isLegalMove(move))
    }

    @Test func testIsKingInCheck_kingUnderAttack_returnsTrue() throws {
        let fen = "8/8/8/8/8/8/5q2/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let validator = MoveValidator(position)
        #expect(validator.isKingInCheck())
    }

    @Test func testIsKingInCheck_startingPosition_returnsFalse() throws {
        let position = try PositionFactory.startingPosition()
        let validator = MoveValidator(position)
        #expect(!validator.isKingInCheck())
    }

    @Test func testPlayerHasLegalMove_startingPosition_returnsTrue() throws {
        let position = try PositionFactory.startingPosition()
        let validator = MoveValidator(position)
        #expect(validator.playerHasLegalMove())
    }

    @Test func testPlayerHasLegalMove_stalemate_returnsFalse() throws {
        let fen = "7k/5Q2/6K1/8/8/8/8/8 b - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let validator = MoveValidator(position)
        #expect(!validator.playerHasLegalMove())
    }

    @Test func testIsSquareAttacked_squareUnderAttack_returnsTrue() throws {
        let fen = "8/8/8/8/8/8/5q2/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let validator = MoveValidator(position)
        #expect(validator.isSquareAttackedByOpponent(row: 1, file: 5))
    }

    @Test func testIsSquareAttacked_squareNotAttacked_returnsFalse() throws {
        let position = try PositionFactory.startingPosition()
        let validator = MoveValidator(position)
        #expect(!validator.isSquareAttackedByOpponent(row: 4, file: 4))
    }

    @Test func testIsCheck_moveGivesCheck_returnsTrue() throws {
        let fen = "7k/8/8/8/8/8/8/3Q3K w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let validator = MoveValidator(position)
        let queen = try #require(position.get(atRow: 1, atFile: 4))
        let move = try #require(queen.createMove("d8", type: .normal, promoteTo: .queen))
        #expect(validator.isCheck(move))
    }

    @Test func testIsCheckMate_matePosition_returnsTrue() throws {
        let fen = "6k1/5ppp/8/8/8/8/8/4R2K w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        let validator = MoveValidator(position)
        let rook = try #require(position.get(atRow: 1, atFile: 5))
        let move = try #require(rook.createMove("e8", type: .normal, promoteTo: .queen))
        #expect(validator.isCheckMate(move))
    }
}
