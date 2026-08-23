import XCTest

final class AnnotationUITests: ChessUITestCase {

    override class func setUp() {
        super.setUp()
        launchShared()
    }

    override func setUp() {
        super.setUp()
        MainActor.assumeIsolated {
            guard let app = Self.sharedApp else { return }
            openGame(app, firstGameTitle)
            // Navigate to end then start so any in-memory user highlights are cleared by navigation
            let navEnd = element(app, "nav-end")
            if navEnd.waitForExistence(timeout: 3) {
                navEnd.click()
            }
            click(app, "nav-start")
        }
    }

    // Normalized board coordinates for a square (not-flipped white-at-bottom orientation).
    // file: a=1…h=8, rank: 1…8
    private func boardCoord(file: Int, rank: Int) -> CGVector {
        let x = (CGFloat(file) - 0.5) / 8.0
        let y = (CGFloat(9 - rank) - 0.5) / 8.0
        return CGVector(dx: x, dy: y)
    }

    func testHighlightsAppearOnAnnotatedMove() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "movelist-Bb5")

        assertExists(app, "highlight-b5", "Red highlight on b5 should appear after navigating to Bb5")
        assertExists(app, "highlight-c6", "Red highlight on c6 should appear after navigating to Bb5")
        assertExists(app, "arrows-overlay", "Arrow overlay should appear after navigating to Bb5")
    }

    func testHighlightsClearAfterNavigatingAway() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "movelist-Bb5")
        assertExists(app, "highlight-b5", "Highlight should be present on Bb5")

        click(app, "movelist-a6")
        assertAbsent(app, "highlight-b5", "Highlight should be gone after navigating to a6")
        assertAbsent(app, "arrows-overlay", "Arrow overlay should be gone after navigating to a6")
    }

    func testHighlightsAbsentOnUnannotatedMove() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "movelist-e4")
        assertAbsent(app, "highlight-e4", "No highlights should appear for an unannotated move")
        assertAbsent(app, "arrows-overlay", "No arrows should appear for an unannotated move")
    }

    func testRightClickAddsUserHighlight() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        let board = element(app, "chessboard")
        board.coordinate(withNormalizedOffset: boardCoord(file: 5, rank: 4)).rightClick()

        assertExists(app, "highlight-e4", "Right-clicking e4 should add a green highlight")
    }

    func testRightClickCyclesHighlightColor() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        let board = element(app, "chessboard")
        let e4 = board.coordinate(withNormalizedOffset: boardCoord(file: 5, rank: 4))

        e4.rightClick()
        assertExists(app, "highlight-e4", "First right-click should add highlight")

        e4.rightClick()
        assertExists(app, "highlight-e4", "Second right-click should cycle color, highlight still present")

        e4.rightClick()
        assertExists(app, "highlight-e4", "Third right-click should cycle color again")

        e4.rightClick()
        assertExists(app, "highlight-e4", "Fourth right-click should cycle to last color")

        e4.rightClick()
        assertAbsent(app, "highlight-e4", "Fifth right-click should remove the highlight")
    }

    func testUserHighlightsClearOnNavigation() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        let board = element(app, "chessboard")
        board.coordinate(withNormalizedOffset: boardCoord(file: 5, rank: 4)).rightClick()
        assertExists(app, "highlight-e4", "User highlight should be present before navigation")

        click(app, "nav-forward")
        assertAbsent(app, "highlight-e4", "User highlight should be cleared after navigating")
    }
}
