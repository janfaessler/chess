import XCTest
@testable import SwiftChessCore

final class FenTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let fens = [
            PositionFactory.startingPositionFen,
            "8/5k2/8/3K4/8/8/8/8 w - - 0 1",
            "8/5k2/8/3K1b2/8/8/8/8 w - - 0 1",
            "8/5k2/8/3K4/8/2B5/8/8 w - - 0 1",
            "8/5k2/8/3K4/6n1/8/8/8 w - - 0 1",
            "8/5k2/8/3K4/8/8/5N2/8 w - - 0 1",
            "8/5k2/b7/3K4/6B1/8/8/8 w - - 0 1",
            "8/5k2/b7/3K4/7B/8/8/8 w - - 0 10",
            "8/5k2/8/3K1b2/8/8/8/6r1 w - - 0 10",
            "8/5k2/8/3K1b2/8/8/1n6/8 w - - 0 10",
        ]
        
        for fen in fens {
            let pos = try XCTUnwrap(PositionFactory.loadPosition(fen))
            let board = ChessGame(pos)
            let exportedPosition = board.position
            let exportedFen = FenBuilder.create(exportedPosition)
            
            XCTAssertEqual(fen, exportedFen)
        }
    }

    func testParse_tooFewFields_throws() {
        XCTAssertThrowsError(try FenParser.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq -"))
    }

    func testParse_emptyString_throws() {
        XCTAssertThrowsError(try FenParser.parse(""))
    }

    func testParse_garbageBoard_throws() {
        XCTAssertThrowsError(try FenParser.parse("this-is-not-a-board w KQkq - 0 1"))
    }

    func testParse_validFen_doesNotThrow() throws {
        XCTAssertNoThrow(try FenParser.parse(PositionFactory.startingPositionFen))
    }
}
