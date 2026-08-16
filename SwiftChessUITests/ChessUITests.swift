import XCTest

final class NavigationUITests: ChessUITestCase {
    
    func testSidebarShowsSeededGames() {
        let app = launchApp()
        assertExists(app, "sidebar-game-\(firstGameTitle)")
        assertExists(app, "sidebar-game-\(secondGameTitle)")
    }

    func testSelectingGameShowsBoardAndEditButton() {
        let app = launchApp()
        openGame(app, firstGameTitle)
        assertExists(app, "chessboard")
        assertExists(app, "edit-game", "Edit Game toolbar button should be shown for a game")
    }

    func testActionsMenuOpensOpenPgnScreen() {
        let app = launchApp()
        openGame(app, firstGameTitle)
        click(app, "actions-menu")
        click(app, "actions-open-pgn")
        XCTAssertTrue(app.staticTexts["Import PGN Files"].waitForExistence(timeout: 5), "Open PGN screen should be shown")
    }
}
