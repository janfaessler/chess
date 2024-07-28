import XCTest
import SwiftChess

final class MoveHistoryTests: XCTestCase {
    
    var testee:MoveListModel?
    
    override func setUpWithError() throws {
        testee = MoveListModel()
    }

    func testMoveHistory() throws {
        
        let testee = try XCTUnwrap(testee)
                
        let game = PgnGameParser.parse("1. e4 e5 2. Nc3 Nf6")
        let containers = StructureFactory.create(game)
        
        
        testee.updateMoveList(containers)
        
        testee.end()
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nc3", "Nf6"])
        
        testee.back()
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nc3"])
        
        testee.back()
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5"])
        
        testee.movePlayed("d3")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "d3"])
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "d3", "d6"])
        let endOfFirstVariation = try XCTUnwrap(testee.currentMove)
        
        testee.back()
        testee.movePlayed("Nf6")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "d3", "Nf6"])
        
        testee.movePlayed("Nc3")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "d3", "Nf6", "Nc3"])
        let endOfSubVariation = try XCTUnwrap(testee.currentMove)

        testee.start()
        XCTAssertEqual(testee.getMoveNotations(), [])

        testee.forward()
        XCTAssertEqual(testee.getMoveNotations(), ["e4"])
        
        testee.forward()
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5"])
        
        testee.forward()
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nc3"])
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nc3", "d6"])

        testee.movePlayed("d3")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nc3", "d6", "d3"])
        let endOfSecondVariation = try XCTUnwrap(testee.currentMove)
        
        testee.end()
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nc3", "Nf6"])

        testee.goToMove(endOfFirstVariation)
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "d3", "d6"])
        
        testee.goToMove(endOfSecondVariation)
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nc3", "d6", "d3"])
        
        testee.goToMove(endOfSubVariation)
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "d3", "Nf6", "Nc3"])

    }
    
    func testUpdateMoves() throws {
        let game = PgnGameParser.parse("1. e4 e5 ( 1... d5 2. d3 ( 2. a3 a6 ) )2. Nc3 ( 2. Nf3 Nf6 3. b3 b6 )  Nf6")
        let containers = StructureFactory.create(game)
        
        let testee = try XCTUnwrap(testee)
        testee.updateMoveList(containers)
        
        XCTAssertEqual(testee.list[0].white?.move, "e4")
        XCTAssertEqual(testee.list[0].black?.move, "e5")
        
        let d5variation = testee.list[0].black?.variations["d5"]
        XCTAssertEqual(d5variation?[0].black?.move, "d5")
        XCTAssertEqual(d5variation?[1].white?.move, "d3")
        
        let a3variation = d5variation?[1].white?.variations["a3"]
        XCTAssertEqual(a3variation?[0].white?.move, "a3")
        XCTAssertEqual(a3variation?[0].black?.move, "a6")
        
        XCTAssertEqual(testee.list[1].white?.move, "Nc3")
        
        let Nf3variation = testee.list[1].white?.variations["Nf3"]
        XCTAssertEqual(Nf3variation?[0].white?.move, "Nf3")
        XCTAssertEqual(Nf3variation?[0].black?.move, "Nf6")
        XCTAssertEqual(Nf3variation?[1].white?.move, "b3")
        XCTAssertEqual(Nf3variation?[1].black?.move, "b6")
        
        XCTAssertEqual(testee.list[1].black?.move, "Nf6")
        
        testee.start()
        XCTAssertNil(testee.currentMove)
        XCTAssertEqual(testee.getMoveNotations(), [])
        
        testee.end()
        XCTAssertEqual(testee.currentMove?.move, "Nf6")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nc3", "Nf6"])
        
        let d3move = try XCTUnwrap(d5variation?[1].white)
        testee.goToMove(d3move)
        XCTAssertEqual(d3move.move, "d3")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "d5", "d3"])

        let a6move = try XCTUnwrap(a3variation?[0].black)
        testee.goToMove(a6move)
        XCTAssertEqual(a6move.move, "a6")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "d5", "a3", "a6"])
        
        let b6move = try XCTUnwrap(Nf3variation?[1].black)
        testee.goToMove(b6move)
        XCTAssertEqual(b6move.move, "b6")
        XCTAssertEqual(testee.getMoveNotations(), ["e4", "e5", "Nf3", "Nf6", "b3", "b6"])


    }

}
