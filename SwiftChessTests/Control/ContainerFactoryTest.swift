import XCTest
import SwiftChess

final class ContainerFactoryTest: XCTestCase {


    func testFactory() throws {
        let game = PgnGameParser.parse("1. e4 e5 2. Nc3 ( 2. d3 d6 ) 2... Nf6 ( 2... d6 3. d3 )")
        let containers = ContainerFactory.create(game)
        
        XCTAssertEqual(containers[0].white?.move, "e4")
        XCTAssertEqual(containers[0].black?.move, "e5")
        XCTAssertEqual(containers[1].white?.move, "Nc3")
        XCTAssertEqual(containers[1].white?.variations["d3"]?[0].white?.move, "d3")
        XCTAssertEqual(containers[1].white?.variations["d3"]?[0].black?.move, "d6")
        XCTAssertEqual(containers[1].black?.move, "Nf6")
        XCTAssertEqual(containers[1].black?.variations["d6"]?[0].black?.move, "d6")
        XCTAssertEqual(containers[1].black?.variations["d6"]?[1].white?.move, "d3")

    }

}
