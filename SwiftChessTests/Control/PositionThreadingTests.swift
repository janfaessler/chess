import XCTest
@testable import SwiftChess
import SwiftChessCore


final class PositionThreadingTests: XCTestCase {

    private func fen(_ position: Position?) throws -> String {
        FenBuilder.create(try XCTUnwrap(position))
    }

    func testNavigation_doesNotReparseSAN() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nf3")

        XCTAssertTrue(testee.position === testee.currentMove?.resultingPosition)

        testee.back()
        XCTAssertTrue(testee.position === testee.currentMove?.resultingPosition)

        testee.end()
        XCTAssertTrue(testee.position === testee.currentMove?.resultingPosition)
    }

    func testPlayedMoves_populateResultingPosition() throws {
        let testee = MoveListModel()
        testee.movePlayed("e4")
        testee.movePlayed("e5")
        testee.movePlayed("Nf3")

        let expected = try fen(PositionFactory.loadPosition(["e4", "e5", "Nf3"]))
        XCTAssertEqual(try fen(testee.currentMove?.resultingPosition), expected)
    }

    func testStructureLoad_threadsPositionsThroughVariations() throws {
        let game = PgnGameParser.parse("1. e4 e5 2. Nc3 ( 2. Nf3 Nc6 ) 2... Nf6")
        let structure = StructureFactory.create(game)

        XCTAssertEqual(try fen(structure.list[0].white?.resultingPosition),
                       try fen(PositionFactory.loadPosition(["e4"])))
        XCTAssertEqual(try fen(structure.list[1].white?.resultingPosition),
                       try fen(PositionFactory.loadPosition(["e4", "e5", "Nc3"])))

        let variation = try XCTUnwrap(structure.list[1].white?.getVariation("Nf3"))
        XCTAssertEqual(try fen(variation.all[0].white?.resultingPosition),
                       try fen(PositionFactory.loadPosition(["e4", "e5", "Nf3"])))
        XCTAssertEqual(try fen(variation.all[0].black?.resultingPosition),
                       try fen(PositionFactory.loadPosition(["e4", "e5", "Nf3", "Nc6"])))
    }

    func testNavigation_nilResultingPosition_fallsBackToReplay() throws {

        let node = MoveModel(move: "e4", color: .white)
        let structure = MoveStructure(line: LineModel([MovePairModel.create(node, moveNumber: 1)]))

        let testee = MoveListModel()
        testee.load(structure)
        testee.forward()

        XCTAssertNil(testee.currentMove?.resultingPosition)
        XCTAssertEqual(try fen(testee.position),
                       try fen(PositionFactory.loadPosition(["e4"])))
    }
}
