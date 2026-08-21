import Testing
@testable import SwiftChess
import SwiftChessCore

struct StructureFactoryTests {

    @Test func testFactory() throws {
        let game = GameData.from(PgnGameParser.parse("1. e4 e5 2. Nc3 ( 2. d3 d6 ) 2... Nf6 ( 2... d6 3. d3 )"))
        let structure = StructureFactory.create(game)

        #expect(structure.list[0].white?.move == "e4")
        #expect(structure.list[0].black?.move == "e5")
        #expect(structure.list[1].white?.move == "Nc3")
        #expect(structure.list[1].white?.getVariation("d3")?.all[0].white?.move == "d3")
        #expect(structure.list[1].white?.getVariation("d3")?.all[0].black?.move == "d6")
        #expect(structure.list[1].black?.move == "Nf6")
        #expect(structure.list[1].black?.getVariation("d6")?.all[0].black?.move == "d6")
        #expect(structure.list[1].black?.getVariation("d6")?.all[1].white?.move == "d3")
    }
}
