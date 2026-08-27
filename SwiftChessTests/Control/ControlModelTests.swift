import Testing
import SwiftChessCore
@testable import SwiftChess

@MainActor
struct ControlModelTests {

    private func makeGame(comment: String? = nil) -> GameData {
        GameData(headers: [:], moves: [], result: "", comment: comment)
    }

    @Test func testInit_withStubEngine_usesInjectedEngine() {
        let stub = StubEngine()
        let model = ControlModel(makeGame(), engine: stub)
        #expect((model.engine as? StubEngine) === stub)
    }

    @Test func testInit_withoutEngine_hasNoLines() {
        let stub = StubEngine()
        let model = ControlModel(makeGame(), engine: stub)
        #expect(model.lines.isEmpty)
    }

    @Test func testInit_hasBoardWithStartingFigures() {
        let stub = StubEngine()
        let model = ControlModel(makeGame(), engine: stub)
        #expect(model.board.figures.count == 32)
    }

    @Test func testInit_isNotLoading() {
        let stub = StubEngine()
        let model = ControlModel(makeGame(), engine: stub)
        #expect(!model.isLoading)
    }

    @Test func testComment_noMoveSelected_returnsGameComment() {
        let stub = StubEngine()
        let model = ControlModel(makeGame(comment: "test comment"), engine: stub)
        #expect(model.comment == "test comment")
    }

    @Test func testStart_calledTwice_doesNotCrash() {
        let stub = StubEngine()
        let model = ControlModel(makeGame(), engine: stub)
        model.start()
        model.start()
    }
}
