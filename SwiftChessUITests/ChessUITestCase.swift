import XCTest

@MainActor
class ChessUITestCase: XCTestCase {

    let firstGameTitle = "Alice - Bob"
    let secondGameTitle = "Carol - Dave"
    let seededCollectionName = "UITest Collection"

    nonisolated(unsafe) static var sharedApp: XCUIApplication?

    nonisolated override class func tearDown() {
        MainActor.assumeIsolated {
            sharedApp?.terminate()
            sharedApp = nil
        }
        super.tearDown()
    }

    nonisolated class func launchShared() {
        MainActor.assumeIsolated {
            let app = XCUIApplication()
            app.launchArguments += ["-uiTesting", "-AppleInterfaceStyle", "Dark"]
            app.launch()
            sharedApp = app
        }
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func launchApp(boardFen: String? = nil) -> XCUIApplication {
        if boardFen == nil, let app = Self.sharedApp {
            return app
        }
        let app = XCUIApplication()
        app.launchArguments += ["-uiTesting", "-AppleInterfaceStyle", "Dark"]
        if let boardFen {
            app.launchEnvironment["UITEST_BOARD_FEN"] = boardFen
        }
        app.launch()
        return app
    }
    
    func element(_ app: XCUIApplication, _ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    func assertExists(_ app: XCUIApplication, _ identifier: String, timeout: TimeInterval = 5, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        let found = element(app, identifier).waitForExistence(timeout: timeout)
        XCTAssertTrue(found, message.isEmpty ? "Expected element '\(identifier)' to exist" : message, file: file, line: line)
    }

    func assertAbsent(_ app: XCUIApplication, _ identifier: String, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertFalse(element(app, identifier).exists, message.isEmpty ? "Expected element '\(identifier)' to be absent" : message, file: file, line: line)
    }

    func click(_ app: XCUIApplication, _ identifier: String, file: StaticString = #filePath, line: UInt = #line) {
        let el = element(app, identifier)
        XCTAssertTrue(el.waitForExistence(timeout: 5), "Cannot click missing element '\(identifier)'", file: file, line: line)
        el.click()
    }

    func clickMenuItem(_ app: XCUIApplication, _ title: String, file: StaticString = #filePath, line: UInt = #line) {
        let item = app.menuItems[title]
        XCTAssertTrue(item.waitForExistence(timeout: 5), "Cannot click missing menu item '\(title)'", file: file, line: line)
        item.click()
    }

    func openGame(_ app: XCUIApplication, _ title: String) {
        click(app, "sidebar-game-\(title)")
        assertExists(app, "chessboard", "Board should appear after opening a game")
    }
}
