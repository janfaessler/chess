import XCTest

final class EngineAnalysisUITests: ChessUITestCase {

    func testAnalysisPanelIsShown() {
        let app = launchApp()
        openGame(app, firstGameTitle)

        assertExists(app, "analysis-panel", "Analysis panel should be visible with engine output")
        assertExists(app, "engine-line-1", "First engine line should be listed")
    }
}
