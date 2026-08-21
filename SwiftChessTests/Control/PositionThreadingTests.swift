import Testing
@testable import SwiftChess
import SwiftChessCore

struct PositionThreadingTests {

    private func fen(_ position: Position?) throws -> String {
        FenBuilder.create(try #require(position))
    }

    @Test func testNavigation_doesNotReparseSAN() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nf3")

        #expect(testee.position === testee.currentMove?.resultingPosition)

        testee.back()
        #expect(testee.position === testee.currentMove?.resultingPosition)

        testee.end()
        #expect(testee.position === testee.currentMove?.resultingPosition)
    }

    @Test func testPlayedMoves_populateResultingPosition() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nf3")

        let expected = try fen(PositionFactory.loadPosition(["e4", "e5", "Nf3"]))
        #expect(try fen(testee.currentMove?.resultingPosition) == expected)
    }

    @Test func testStructureLoad_threadsPositionsThroughVariations() throws {
        let game = PgnGameParser.parse("1. e4 e5 2. Nc3 ( 2. Nf3 Nc6 ) 2... Nf6")
        let structure = StructureFactory.create(game)

        #expect(try fen(structure.list[0].white?.resultingPosition) ==
                try fen(PositionFactory.loadPosition(["e4"])))
        #expect(try fen(structure.list[1].white?.resultingPosition) ==
                try fen(PositionFactory.loadPosition(["e4", "e5", "Nc3"])))

        let variation = try #require(structure.list[1].white?.getVariation("Nf3"))
        #expect(try fen(variation.all[0].white?.resultingPosition) ==
                try fen(PositionFactory.loadPosition(["e4", "e5", "Nf3"])))
        #expect(try fen(variation.all[0].black?.resultingPosition) ==
                try fen(PositionFactory.loadPosition(["e4", "e5", "Nf3", "Nc6"])))
    }

    @Test func testNavigation_nilResultingPosition_fallsBackToReplay() throws {
        let node = MoveModel(move: "e4", color: .white)
        let structure = MoveStructure(line: LineModel([MovePairModel.create(node, moveNumber: 1)]))

        let testee = MoveListModel()
        testee.load(structure)
        testee.forward()

        #expect(testee.currentMove?.resultingPosition == nil)
        let expected = try fen(PositionFactory.loadPosition(["e4"]))
        #expect(try fen(testee.position) == expected)
    }
}
