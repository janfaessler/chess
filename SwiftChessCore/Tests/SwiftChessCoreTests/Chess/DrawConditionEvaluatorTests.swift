import Testing
@testable import SwiftChessCore

struct DrawConditionEvaluatorTests {

    @Test func testInsufficientMaterial_onlyKings_isTrue() {
        let figures: [any ChessPiece] = [
            PieceFactory.create("e1", type: .king, color: .white)!,
            PieceFactory.create("e8", type: .king, color: .black)!
        ]
        #expect(DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_kingAndKnight_isTrue() {
        let figures: [any ChessPiece] = [
            PieceFactory.create("e1", type: .king, color: .white)!,
            PieceFactory.create("g1", type: .knight, color: .white)!,
            PieceFactory.create("e8", type: .king, color: .black)!
        ]
        #expect(DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_kingAndBishop_isTrue() {
        let figures: [any ChessPiece] = [
            PieceFactory.create("e1", type: .king, color: .white)!,
            PieceFactory.create("c1", type: .bishop, color: .white)!,
            PieceFactory.create("e8", type: .king, color: .black)!
        ]
        #expect(DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_bishopsOnSameSquareColor_isTrue() {
        let figures: [any ChessPiece] = [
            PieceFactory.create("e1", type: .king, color: .white)!,
            PieceFactory.create("c1", type: .bishop, color: .white)!,
            PieceFactory.create("e8", type: .king, color: .black)!,
            PieceFactory.create("f8", type: .bishop, color: .black)!
        ]
        #expect(DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_bishopsOnOppositeSquareColor_isFalse() {
        let figures: [any ChessPiece] = [
            PieceFactory.create("e1", type: .king, color: .white)!,
            PieceFactory.create("c1", type: .bishop, color: .white)!,
            PieceFactory.create("e8", type: .king, color: .black)!,
            PieceFactory.create("c8", type: .bishop, color: .black)!
        ]
        #expect(!DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_kingAndRook_isFalse() {
        let figures: [any ChessPiece] = [
            PieceFactory.create("e1", type: .king, color: .white)!,
            PieceFactory.create("a1", type: .rook, color: .white)!,
            PieceFactory.create("e8", type: .king, color: .black)!
        ]
        #expect(!DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_kingAndQueen_isFalse() {
        let figures: [any ChessPiece] = [
            PieceFactory.create("e1", type: .king, color: .white)!,
            PieceFactory.create("d1", type: .queen, color: .white)!,
            PieceFactory.create("e8", type: .king, color: .black)!
        ]
        #expect(!DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testThreefoldRepetition_atThreshold_isTrue() {
        let hash = 42
        #expect(DrawConditionEvaluator.isThreefoldRepetition(positionCount: [hash: 3], currentHash: hash))
    }

    @Test func testThreefoldRepetition_aboveThreshold_isTrue() {
        let hash = 42
        #expect(DrawConditionEvaluator.isThreefoldRepetition(positionCount: [hash: 5], currentHash: hash))
    }

    @Test func testThreefoldRepetition_belowThreshold_isFalse() {
        let hash = 42
        #expect(!DrawConditionEvaluator.isThreefoldRepetition(positionCount: [hash: 2], currentHash: hash))
    }

    @Test func testThreefoldRepetition_hashNotPresent_isFalse() {
        #expect(!DrawConditionEvaluator.isThreefoldRepetition(positionCount: [:], currentHash: 99))
    }

    @Test func test50MoveRule_atLimit_isTrue() {
        #expect(DrawConditionEvaluator.has50MoveRuleTriggered(halfmoveClock: 100))
    }

    @Test func test50MoveRule_aboveLimit_isTrue() {
        #expect(DrawConditionEvaluator.has50MoveRuleTriggered(halfmoveClock: 101))
    }

    @Test func test50MoveRule_belowLimit_isFalse() {
        #expect(!DrawConditionEvaluator.has50MoveRuleTriggered(halfmoveClock: 99))
    }

    @Test func test50MoveRule_atZero_isFalse() {
        #expect(!DrawConditionEvaluator.has50MoveRuleTriggered(halfmoveClock: 0))
    }

    @Test func testInsufficientMaterial_throughChessGame_returnsDrawState() throws {
        let position = try #require(PositionFactory.loadPosition("8/5k2/8/3K4/8/8/8/8 w - - 0 1"))
        let game = ChessGame(position)
        #expect(game.getGameState() == .drawByInsufficientMaterial)
    }

    @Test func testThreefoldRepetition_throughChessGame_returnsDrawState() throws {
        let position = try PositionFactory.startingPosition()
        let game = ChessGame(position)
        for notation in ["Nf3", "Nf6", "Ng1", "Ng8", "Nf3", "Nf6", "Ng1", "Ng8", "Nf3"] {
            try game.move(notation)
        }
        #expect(game.getGameState() == .drawByRepetition)
    }

    @Test func test50MoveRule_throughChessGame_returnsDrawState() throws {
        let position = try #require(PositionFactory.loadPosition("4k3/8/8/8/8/8/R7/4K3 w - - 100 60"))
        let game = ChessGame(position)
        #expect(game.getGameState() == .drawBy50MoveRule)
    }
}
