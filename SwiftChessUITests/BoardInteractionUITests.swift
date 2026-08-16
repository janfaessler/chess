import XCTest

final class BoardInteractionUITests: ChessUITestCase {

    private func play(_ app: XCUIApplication, from: String, to: String) {
        click(app, "figure-\(from)")
        click(app, "target-\(to)")
    }

    func testPawnMove() {
        let app = launchApp(boardFen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
        openGame(app, firstGameTitle)

        play(app, from: "e2", to: "e4")

        assertExists(app, "figure-e4", "Pawn should now be on e4")
        assertAbsent(app, "figure-e2", "Pawn should have left e2")
    }

    func testCapture() {
        let app = launchApp(boardFen: "4k3/8/8/3p4/4P3/8/8/4K3 w - - 0 1")
        openGame(app, firstGameTitle)

        play(app, from: "e4", to: "d5")

        assertExists(app, "figure-d5", "White pawn should have captured on d5")
        assertAbsent(app, "figure-e4", "White pawn should have left e4")
    }

    func testKingsideCastling() {
        let app = launchApp(boardFen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
        openGame(app, firstGameTitle)

        play(app, from: "e1", to: "g1")

        assertExists(app, "figure-g1", "King should have castled to g1")
        assertExists(app, "figure-f1", "Rook should have moved to f1")
        assertAbsent(app, "figure-e1", "King should have left e1")
    }

    func testEnPassant() {
        let app = launchApp(boardFen: "4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1")
        openGame(app, firstGameTitle)

        play(app, from: "e5", to: "d6")

        assertExists(app, "figure-d6", "White pawn should be on d6 after en passant")
        assertAbsent(app, "figure-d5", "Captured black pawn should be gone from d5")
        assertAbsent(app, "figure-e5", "White pawn should have left e5")
    }

    func testPromotionShowsPickerAndPromotes() {
        let app = launchApp(boardFen: "4k3/P7/8/8/8/8/8/4K3 w - - 0 1")
        openGame(app, firstGameTitle)

        play(app, from: "a7", to: "a8")

        assertExists(app, "promotion-picker", "Promotion picker should appear")
        click(app, "promote-queen")
        assertExists(app, "figure-a8", "Promoted piece should be on a8")
        assertAbsent(app, "promotion-picker", "Promotion picker should be dismissed")
    }

    func testCheckmateShowsResultOverlay() {
        let app = launchApp(boardFen: "7k/6pp/8/8/8/8/8/R6K w - - 10 20")
        openGame(app, firstGameTitle)

        play(app, from: "a1", to: "a8")

        assertExists(app, "game-result", "Result overlay should appear on checkmate")
    }
}
