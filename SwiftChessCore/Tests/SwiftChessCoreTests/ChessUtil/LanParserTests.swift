import Testing
@testable import SwiftChessCore

struct LanParserTests {

    @Test func testParse_shortString_returnsNil() {
        let position = PositionFactory.startingPosition()
        #expect(LanParser.parse(lan: "e2", position: position) == nil)
        #expect(LanParser.parse(lan: "", position: position) == nil)
    }

    @Test func testParse_normalMove_ok() {
        let position = PositionFactory.startingPosition()
        let move = LanParser.parse(lan: "e2e4", position: position)
        #expect(move != nil)
        #expect(move?.row == 4)
        #expect(move?.file == 5)
    }

    @Test func testParse_promotion_setsPromoteTo() throws {
        let position = try #require(PositionFactory.loadPosition("8/4P3/8/8/8/8/8/4K1k1 w - - 0 1"))
        let move = LanParser.parse(lan: "e7e8n", position: position)
        #expect(move != nil)
        #expect(move?.promoteTo == .knight)
    }
}
