import XCTest
@testable import SwiftChessCore

final class LanParserTests: XCTestCase {

    func testParse_shortString_returnsNil() {
        let position = PositionFactory.startingPosition()
        XCTAssertNil(LanParser.parse(lan: "e2", position: position))
        XCTAssertNil(LanParser.parse(lan: "", position: position))
    }

    func testParse_normalMove_ok() {
        let position = PositionFactory.startingPosition()
        let move = LanParser.parse(lan: "e2e4", position: position)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.row, 4)
        XCTAssertEqual(move?.file, 5)
    }

    func testParse_promotion_setsPromoteTo() throws {
        let position = try XCTUnwrap(PositionFactory.loadPosition("8/4P3/8/8/8/8/8/4K1k1 w - - 0 1"))
        let move = LanParser.parse(lan: "e7e8n", position: position)
        XCTAssertNotNil(move)
        XCTAssertEqual(move?.promoteTo, .knight)
    }
}
