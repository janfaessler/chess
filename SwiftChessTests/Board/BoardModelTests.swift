import Testing
import SwiftChessCore
@testable import SwiftChess

struct BoardModelTests {

    @Test func testInit_hasAllStartingFigures() {
        let model = BoardModel()
        #expect(model.figures.count == 32)
    }

    @Test func testInit_noFocus() {
        let model = BoardModel()
        #expect(model.focus == nil)
    }

    @Test func testSetFocus_storesPiece() throws {
        let model = BoardModel()
        let piece = try #require(model.figures.first)
        model.setFocus(piece)
        #expect(model.focus === piece)
    }

    @Test func testClearFocus_removesFocus() throws {
        let model = BoardModel()
        let piece = try #require(model.figures.first)
        model.setFocus(piece)
        model.clearFocus()
        #expect(model.focus == nil)
    }

    @Test func testGetLegalMoves_noFocus_returnsEmpty() {
        let model = BoardModel()
        #expect(model.getLegalMoves().isEmpty)
    }

    @Test func testGetLegalMoves_withWhitePawnFocus_returnsLegalMoves() throws {
        let model = BoardModel()
        let pawn = try #require(model.figures.first(where: { $0.type == .pawn && $0.color == .white }))
        model.setFocus(pawn)
        let moves = model.getLegalMoves()
        #expect(!moves.isEmpty)
    }

    @Test func testUpdatePosition_replacesAllFigures() throws {
        let model = BoardModel()
        let fen = "8/8/8/8/8/8/8/4K3 w - - 0 1"
        let position = try #require(PositionFactory.loadPosition(fen))
        model.updatePosition(position)
        #expect(model.figures.count == 1)
        #expect(model.figures.first?.type == .king)
    }

    @Test func testResult_initialState_isNotDisplayed() {
        let model = BoardModel()
        #expect(!model.result.shouldDisplay())
    }

    @Test func testShouldShowPromotionView_initialState_isFalse() {
        let model = BoardModel()
        #expect(!model.shouldShowPromotionView)
    }
}
