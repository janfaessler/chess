import Testing
@testable import SwiftChess
import SwiftChessCore

struct MoveHistoryTests {

    let testee = MoveListModel()

    @Test func testMoveHistory() throws {
        let game = GameData.from(PgnGameParser.parse("1. e4 e5 2. Nc3 Nf6"))
        let containers = StructureFactory.create(game)

        testee.load(containers)

        testee.end()
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nc3", "Nf6"])

        testee.back()
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nc3"])

        testee.back()
        #expect(testee.getMoveNotations() == ["e4", "e5"])

        testee.movePlayed("d3")
        #expect(testee.getMoveNotations() == ["e4", "e5", "d3"])

        testee.movePlayed("d6")
        #expect(testee.getMoveNotations() == ["e4", "e5", "d3", "d6"])
        let endOfFirstVariation = try #require(testee.currentMove)

        testee.back()
        testee.movePlayed("Nf6")
        #expect(testee.getMoveNotations() == ["e4", "e5", "d3", "Nf6"])

        testee.movePlayed("Nc3")
        #expect(testee.getMoveNotations() == ["e4", "e5", "d3", "Nf6", "Nc3"])
        let endOfSubVariation = try #require(testee.currentMove)

        testee.start()
        #expect(testee.getMoveNotations() == [])

        testee.forward()
        #expect(testee.getMoveNotations() == ["e4"])

        testee.forward()
        #expect(testee.getMoveNotations() == ["e4", "e5"])

        testee.forward()
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nc3"])

        testee.movePlayed("d6")
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nc3", "d6"])

        testee.movePlayed("d3")
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nc3", "d6", "d3"])
        let endOfSecondVariation = try #require(testee.currentMove)

        testee.end()
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nc3", "Nf6"])

        testee.goToMove(endOfFirstVariation)
        #expect(testee.getMoveNotations() == ["e4", "e5", "d3", "d6"])

        testee.goToMove(endOfSecondVariation)
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nc3", "d6", "d3"])

        testee.goToMove(endOfSubVariation)
        #expect(testee.getMoveNotations() == ["e4", "e5", "d3", "Nf6", "Nc3"])
    }

    @Test func testUpdateMoves() throws {
        let game = GameData.from(PgnGameParser.parse("1. e4 e5 ( 1... d5 2. d3 ( 2. a3 a6 ) )2. Nc3 ( 2. Nf3 Nf6 3. b3 b6 )  Nf6"))
        let containers = StructureFactory.create(game)

        testee.load(containers)

        #expect(testee.list[0].white?.move == "e4")
        #expect(testee.list[0].black?.move == "e5")

        let d5variation = testee.list[0].black?.getVariation("d5")?.all
        #expect(d5variation?[0].black?.move == "d5")
        #expect(d5variation?[1].white?.move == "d3")

        let a3variation = d5variation?[1].white?.getVariation("a3")?.all
        #expect(a3variation?[0].white?.move == "a3")
        #expect(a3variation?[0].black?.move == "a6")

        #expect(testee.list[1].white?.move == "Nc3")

        let Nf3variation = testee.list[1].white?.getVariation("Nf3")?.all
        #expect(Nf3variation?[0].white?.move == "Nf3")
        #expect(Nf3variation?[0].black?.move == "Nf6")
        #expect(Nf3variation?[1].white?.move == "b3")
        #expect(Nf3variation?[1].black?.move == "b6")

        #expect(testee.list[1].black?.move == "Nf6")

        testee.start()
        #expect(testee.currentMove == nil)
        #expect(testee.getMoveNotations() == [])

        testee.end()
        #expect(testee.currentMove?.move == "Nf6")
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nc3", "Nf6"])

        let d3move = try #require(d5variation?[1].white)
        testee.goToMove(d3move)
        #expect(d3move.move == "d3")
        #expect(testee.getMoveNotations() == ["e4", "d5", "d3"])

        let a6move = try #require(a3variation?[0].black)
        testee.goToMove(a6move)
        #expect(a6move.move == "a6")
        #expect(testee.getMoveNotations() == ["e4", "d5", "a3", "a6"])

        let b6move = try #require(Nf3variation?[1].black)
        testee.goToMove(b6move)
        #expect(b6move.move == "b6")
        #expect(testee.getMoveNotations() == ["e4", "e5", "Nf3", "Nf6", "b3", "b6"])
    }
}
