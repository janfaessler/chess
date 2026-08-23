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

    func testIllegalMoveIsRejected() {
        let app = launchApp(boardFen: "4k3/8/8/8/8/8/4P3/4K3 w - - 1 1")
        openGame(app, firstGameTitle)

        click(app, "figure-e2")
        assertAbsent(app, "target-e1", "Pawn cannot move backward — target must not appear")

        click(app, "figure-e1")
        assertExists(app, "figure-e2", "Pawn must remain on e2 after illegal move attempt")
    }

    func testQueensideCastling() {
        let app = launchApp(boardFen: "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1")
        openGame(app, firstGameTitle)

        play(app, from: "e1", to: "c1")

        assertExists(app, "figure-c1", "King should have castled to c1")
        assertExists(app, "figure-d1", "Rook should have moved to d1")
        assertAbsent(app, "figure-e1", "King should have left e1")
        assertAbsent(app, "figure-a1", "Rook should have left a1")
    }

    func testStalemateShowsResultOverlay() {
        // k=a8, K=c6, Q=b2 — Qb6 travels the clear b-file; black king a8 has no legal moves and is not in check
        let app = launchApp(boardFen: "k7/8/2K5/8/8/8/1Q6/8 w - - 1 10")
        openGame(app, firstGameTitle)

        play(app, from: "b2", to: "b6")

        assertExists(app, "game-result", "Result overlay should appear on stalemate")
    }
}
