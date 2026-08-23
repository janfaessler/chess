import XCTest

final class MoveListEditUITests: ChessUITestCase {

    // MARK: - Delete variation confirmation

    func testDeleteVariationShowsConfirmationDialog() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "variation-delete")

        let appeared = app.buttons["Delete"].waitForExistence(timeout: 5)
        XCTAssertTrue(appeared, "Confirmation alert should appear with a Delete button")
        XCTAssertTrue(app.buttons["Cancel"].exists, "Confirmation alert should have a Cancel button")
    }

    func testDeleteVariationCancelKeepsVariation() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "variation-delete")
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].click()

        assertExists(app, "variation-view", "Variation should still be visible after cancelling")
    }

    func testDeleteVariationConfirmRemovesVariation() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        click(app, "variation-delete")
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 5))
        app.buttons["Delete"].click()

        let gone = !app.descendants(matching: .any)
            .matching(identifier: "variation-delete")
            .firstMatch
            .waitForExistence(timeout: 3)
        XCTAssertTrue(gone, "Variation delete button should be gone after confirming deletion")
    }

    // MARK: - Delete from here confirmation

    func testDeleteFromHereShowsConfirmationDialog() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        element(app, "movelist-e4").rightClick()
        clickMenuItem(app, "Delete from here")

        let appeared = app.buttons["Delete"].waitForExistence(timeout: 5)
        XCTAssertTrue(appeared, "Confirmation alert should appear with a Delete button")
        XCTAssertTrue(app.buttons["Cancel"].exists, "Confirmation alert should have a Cancel button")
    }

    func testDeleteFromHereCancelKeepsMove() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        element(app, "movelist-e4").rightClick()
        clickMenuItem(app, "Delete from here")
        XCTAssertTrue(app.buttons["Cancel"].waitForExistence(timeout: 5))
        app.buttons["Cancel"].click()

        assertExists(app, "movelist-e4", "Move should still be in the list after cancelling")
    }

    func testDeleteFromHereConfirmDeletesMove() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        element(app, "movelist-e4").rightClick()
        clickMenuItem(app, "Delete from here")
        XCTAssertTrue(app.buttons["Delete"].waitForExistence(timeout: 5))
        app.buttons["Delete"].click()

        let gone = !app.descendants(matching: .any)
            .matching(identifier: "movelist-e4")
            .firstMatch
            .waitForExistence(timeout: 3)
        XCTAssertTrue(gone, "Move should be gone from the list after confirming deletion")
    }
}
