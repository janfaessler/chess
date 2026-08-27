import Testing
@testable import SwiftChess
import SwiftChessCore

struct PositionThreadingTests {

    private func fen(_ position: Position?) -> String {
        do {
            return FenBuilder.create(try #require(position))
        } catch {
            return "\(error)"
        }
    }

    @Test func testNavigation_doesNotReparseSAN() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nf3")

        #expect(fen(testee.position) == fen(testee.currentMove?.resultingPosition))

        testee.back()
        #expect(fen(testee.position) == fen(testee.currentMove?.resultingPosition))

        testee.end()
        #expect(fen(testee.position) == fen(testee.currentMove?.resultingPosition))
    }

    @Test func testPlayedMoves_populateResultingPosition() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nf3")

        #expect(fen(testee.currentMove?.resultingPosition) == fen(PositionFactory.loadPosition(["e4", "e5", "Nf3"])))
    }

    @Test func testStructureLoad_threadsPositionsThroughVariations() throws {
        let pgnGame = try #require(PgnParser.parse("1. e4 e5 2. Nc3 ( 2. Nf3 Nc6 ) 2... Nf6").first)
        let game = GameData.from(pgnGame)
        let structure = StructureFactory.create(game)

        #expect(fen(structure.list[0].white?.resultingPosition) == fen(PositionFactory.loadPosition(["e4"])))
        #expect(fen(structure.list[1].white?.resultingPosition) == fen(PositionFactory.loadPosition(["e4", "e5", "Nc3"])))

        let variation = try #require(structure.list[1].white?.getVariation("Nf3"))
        #expect(fen(variation.all[0].white?.resultingPosition) == fen(PositionFactory.loadPosition(["e4", "e5", "Nf3"])))
        #expect(fen(variation.all[0].black?.resultingPosition) == fen(PositionFactory.loadPosition(["e4", "e5", "Nf3", "Nc6"])))
    }

    @Test func testNavigation_nilResultingPosition_fallsBackToReplay() throws {
        let node = MoveModel(move: "e4", color: .white)
        let structure = MoveStructure(line: LineModel([MovePairModel.create(node, moveNumber: 1)]))

        let testee = MoveListModel()
        testee.load(structure)
        testee.forward()

        #expect(testee.currentMove?.resultingPosition == nil)
        #expect(fen(testee.position) == fen(PositionFactory.loadPosition(["e4"])))
    }
}
