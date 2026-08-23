import Testing
@testable import SwiftChessCore

struct DrawConditionEvaluatorTests {

    // MARK: - isInsufficientMaterial

    @Test func testInsufficientMaterial_onlyKings_isTrue() {
        let figures: [any ChessFigure] = [
            Figure.create("e1", type: .king, color: .white)!,
            Figure.create("e8", type: .king, color: .black)!
        ]
        #expect(DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_kingAndKnight_isTrue() {
        let figures: [any ChessFigure] = [
            Figure.create("e1", type: .king, color: .white)!,
            Figure.create("g1", type: .knight, color: .white)!,
            Figure.create("e8", type: .king, color: .black)!
        ]
        #expect(DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_kingAndBishop_isTrue() {
        let figures: [any ChessFigure] = [
            Figure.create("e1", type: .king, color: .white)!,
            Figure.create("c1", type: .bishop, color: .white)!,
            Figure.create("e8", type: .king, color: .black)!
        ]
        #expect(DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_bishopsOnSameSquareColor_isTrue() {
        // c1: (row1+file3)%2=0 (dark), f8: (row8+file6)%2=0 (dark) — same square color
        let figures: [any ChessFigure] = [
            Figure.create("e1", type: .king, color: .white)!,
            Figure.create("c1", type: .bishop, color: .white)!,
            Figure.create("e8", type: .king, color: .black)!,
            Figure.create("f8", type: .bishop, color: .black)!
        ]
        #expect(DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_bishopsOnOppositeSquareColor_isFalse() {
        // c1: (row1+file3)%2=0 (dark), c8: (row8+file3)%2=1 (light) — different square color
        let figures: [any ChessFigure] = [
            Figure.create("e1", type: .king, color: .white)!,
            Figure.create("c1", type: .bishop, color: .white)!,
            Figure.create("e8", type: .king, color: .black)!,
            Figure.create("c8", type: .bishop, color: .black)!
        ]
        #expect(!DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_kingAndRook_isFalse() {
        let figures: [any ChessFigure] = [
            Figure.create("e1", type: .king, color: .white)!,
            Figure.create("a1", type: .rook, color: .white)!,
            Figure.create("e8", type: .king, color: .black)!
        ]
        #expect(!DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    @Test func testInsufficientMaterial_kingAndQueen_isFalse() {
        let figures: [any ChessFigure] = [
            Figure.create("e1", type: .king, color: .white)!,
            Figure.create("d1", type: .queen, color: .white)!,
            Figure.create("e8", type: .king, color: .black)!
        ]
        #expect(!DrawConditionEvaluator.isInsufficientMaterial(figures: figures))
    }

    // MARK: - isThreefoldRepetition

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

    // MARK: - has50MoveRuleTriggered

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
}
