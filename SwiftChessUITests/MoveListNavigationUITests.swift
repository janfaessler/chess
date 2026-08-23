import XCTest

final class MoveListNavigationUITests: ChessUITestCase {

    func testForwardPlaysFirstMove() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "nav-forward")

        assertExists(app, "figure-e4", "Board should advance to the position after 1. e4")
    }

    func testEndThenStartNavigatesWholeGame() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "nav-end")
        assertExists(app, "figure-a6", "Jumping to end should reach the final position (…a6)")

        click(app, "nav-start")
        assertExists(app, "figure-e2", "Jumping to start should restore the initial position")
        assertAbsent(app, "figure-e4", "No moves should be applied at the start position")
    }

    func testClickingMoveJumpsToThatPosition() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "movelist-Nf3")

        assertExists(app, "figure-f3", "Clicking Nf3 should place the knight on f3")
    }

    func testKeyboardArrowNavigation() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        app.typeKey(.rightArrow, modifierFlags: [])
        assertExists(app, "figure-e4", "Right arrow should play the first move")

        app.typeKey(.leftArrow, modifierFlags: [])
        assertExists(app, "figure-e2", "Left arrow should undo the move")
    }

    func testVariationsAlwaysVisibleForMoveWithVariations() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        assertExists(app, "variation-view", "Variations should always be visible without requiring a click")
    }
}
