import XCTest
import SwiftChess

final class MoveListTests: XCTestCase {

    var testee:MoveListModel?
    var moves:[any StringProtocol]?
    
    override func setUpWithError() throws {
        testee = MoveListModel()
        moves = []
    }

    func testTopLevelMoveNavigation() throws {
        let testee = try XCTUnwrap(testee)

        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }
        
        testee.start()
        XCTAssertTrue(testee.isCurrentMove(nil))
        for move in testMoves {
            testee.forward()
            XCTAssertEqual(testee.currentMove?.move, move)
        }
        
        testee.start()
        testee.end()
        
        for move in testMoves.reversed() {
            XCTAssertEqual(testee.currentMove?.move, move)
            testee.back()
        }
        XCTAssertNil(testee.currentMove)
    }
    
    func testMoveVariationOnBlack() throws {
        let testee = try XCTUnwrap(testee)

        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Nc3")
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "e5")
        
        testee.movePlayed("Bc4")
        XCTAssertEqual(testee.currentMove?.move, "Bc4")

        testee.movePlayed("Bc5")
        XCTAssertEqual(testee.currentMove?.move, "Bc5")

        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Bc4")
        testee.forward()
        XCTAssertEqual(testee.currentMove?.move, "Bc5")
        
        testee.movePlayed("d3")
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.currentMove?.move, "d6")
        
        let variation = testee.rows[1].white?.variations["Bc4"]
        XCTAssertEqual(variation?[0].moveNumber, 2)
        XCTAssertEqual(variation?[0].white!.move, "Bc4")
        XCTAssertEqual(variation?[0].white!.variations.count, 0)
        XCTAssertEqual(variation?[0].black!.move, "Bc5")
        XCTAssertEqual(variation?[0].black!.variations.count, 0)
        XCTAssertEqual(variation?[1].moveNumber, 3)
        XCTAssertEqual(variation?[1].white!.move, "d3")
        XCTAssertEqual(variation?[1].white!.variations.count, 0)
        XCTAssertEqual(variation?[1].black!.move, "d6")
        XCTAssertEqual(variation?[1].black!.variations.count, 0)

    }
    
    func testMoveVariationOnWhite() throws {
        let testee = try XCTUnwrap(testee)

        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        for move in testMoves {
            testee.movePlayed(move)
        }
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Nc3")
        
        testee.movePlayed("Bc5")
        XCTAssertEqual(testee.currentMove?.move, "Bc5")

        testee.movePlayed("Bc4")
        XCTAssertEqual(testee.currentMove?.move, "Bc4")

        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Bc5")
        testee.forward()
        XCTAssertEqual(testee.currentMove?.move, "Bc4")
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.currentMove?.move, "d6")
        
        testee.movePlayed("d3")
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        testee.back()
        testee.movePlayed("d3")
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        let variation = testee.rows[1].black?.variations["Bc5"]
        XCTAssertEqual(variation?[0].moveNumber, 2)
        XCTAssertNil(variation?[0].white)
        XCTAssertEqual(variation?[0].black!.move, "Bc5")
        XCTAssertEqual(variation?[0].black!.variations.count, 0)
        XCTAssertEqual(variation?[1].moveNumber, 3)
        XCTAssertEqual(variation?[1].white!.move, "Bc4")
        XCTAssertEqual(variation?[1].white!.variations.count, 0)
        XCTAssertEqual(variation?[1].black!.move, "d6")
        XCTAssertEqual(variation?[1].black!.variations.count, 0)
        XCTAssertEqual(variation?[2].moveNumber, 4)
        XCTAssertEqual(variation?[2].white!.move, "d3")
        XCTAssertEqual(variation?[2].white!.variations.count, 0)
        XCTAssertNil(variation?[2].black)
    }
    
    func testGoToMoveWithTwoVariations() throws {
        let testee = try XCTUnwrap(testee)

        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            testee.movePlayed(move)
        }
        
        let variationStart = try XCTUnwrap(testee.rows[0].black)
        testee.goToMove(variationStart)
        XCTAssertEqual(testee.currentMove?.move, variationStart.move)
        
        testee.movePlayed("Bc4")
        XCTAssertEqual(testee.currentMove?.move, "Bc4")

        testee.movePlayed("Bc5")
        XCTAssertEqual(testee.currentMove?.move, "Bc5")
        
        testee.goToMove(variationStart)
        XCTAssertEqual(testee.currentMove?.move, variationStart.move)

        testee.movePlayed("d3")
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.currentMove?.move, "d6")
        
        testee.goToMove(try XCTUnwrap(testee.rows[1].white?.variations["Bc4"]?[0].white))
        XCTAssertEqual(testee.currentMove?.move, "Bc4")
        
        XCTAssertEqual(testee.rows[1].white?.variations.count, 2)
        let variationD3 = testee.rows[1].white?.variations["d3"]
        XCTAssertEqual(variationD3?[0].white!.move, "d3")
        XCTAssertEqual(variationD3?[0].white!.variations.count, 0)
        XCTAssertEqual(variationD3?[0].black!.move, "d6")
        XCTAssertEqual(variationD3?[0].black!.variations.count, 0)

        let variationBc4 = testee.rows[1].white?.variations["Bc4"]
        XCTAssertEqual(variationBc4?[0].white!.move, "Bc4")
        XCTAssertEqual(variationBc4?[0].white!.variations.count, 0)
        XCTAssertEqual(variationBc4?[0].black!.move, "Bc5")
        XCTAssertEqual(variationBc4?[0].black!.variations.count, 0)

    }
    
    func testSubVariationBlackOnWhite() throws {
        let testee = try XCTUnwrap(testee)

        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            testee.movePlayed(move)
        }
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Nc3")
        
        testee.movePlayed("Bc5")
        XCTAssertEqual(testee.currentMove?.move, "Bc5")

        testee.movePlayed("Bc4")
        XCTAssertEqual(testee.currentMove?.move, "Bc4")
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.currentMove?.move, "d6")
        
        testee.movePlayed("d3")
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "d6")
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Bc4")
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Bc5")
        
        testee.movePlayed("d3")
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.currentMove?.move, "d6")
        
        testee.movePlayed("Be2")
        XCTAssertEqual(testee.currentMove?.move, "Be2")
        
        XCTAssertEqual(testee.rows[1].black?.variations.count, 1)
        let variation = testee.rows[1].black?.variations["Bc5"]
        XCTAssertEqual(variation?[0].moveNumber, 2)
        XCTAssertEqual(variation?[0].black!.move, "Bc5")
        XCTAssertEqual(variation?[0].black!.variations.count, 0)
        XCTAssertEqual(variation?[1].moveNumber, 3)
        XCTAssertEqual(variation?[1].white!.move, "Bc4")
        XCTAssertEqual(variation?[1].white!.variations.count, 1)
        XCTAssertEqual(variation?[1].black!.move, "d6")
        XCTAssertEqual(variation?[1].black!.variations.count, 0)

        XCTAssertEqual(variation?[2].moveNumber, 4)
        XCTAssertEqual(variation?[2].white!.move, "d3")
        XCTAssertEqual(variation?[2].white!.variations.count, 0)

        let subVariation = variation?[1].white?.variations["d3"]
        XCTAssertEqual(subVariation?[0].moveNumber, 3)
        XCTAssertEqual(subVariation?[0].white!.move, "d3")
        XCTAssertEqual(subVariation?[0].white!.variations.count, 0)
        XCTAssertEqual(subVariation?[0].black!.move, "d6")
        XCTAssertEqual(subVariation?[0].black!.variations.count, 0)

        XCTAssertEqual(subVariation?[1].moveNumber, 4)
        XCTAssertEqual(subVariation?[1].white!.move, "Be2")
        XCTAssertEqual(subVariation?[1].white!.variations.count, 0)
        XCTAssertNil(subVariation?[1].black)

    }
    
    func testSubVariationWhiteOnBlack() throws {
        let testee = try XCTUnwrap(testee)

        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            testee.movePlayed(move)
        }
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Nc3")
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "e5")
        
        
        testee.movePlayed("Bc4")
        XCTAssertEqual(testee.currentMove?.move, "Bc4")
        
        testee.movePlayed("Bc5")
        XCTAssertEqual(testee.currentMove?.move, "Bc5")
        
        testee.movePlayed("d3")
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.currentMove?.move, "d6")

        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Bc5")
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, "Bc4")
        
        testee.movePlayed("d6")
        XCTAssertEqual(testee.currentMove?.move, "d6")
                                                          
        testee.movePlayed("d3")
        XCTAssertEqual(testee.currentMove?.move, "d3")
        
        
        XCTAssertEqual(testee.rows[1].white!.variations.count, 1)
        let variation = testee.rows[1].white?.variations["Bc4"]
        XCTAssertEqual(variation?[0].moveNumber, 2)
        XCTAssertEqual(variation?[0].white!.move, "Bc4")
        XCTAssertEqual(variation?[0].white!.variations.count, 0)
        XCTAssertEqual(variation?[0].black!.move, "Bc5")
        XCTAssertEqual(variation?[0].black!.variations.count, 1)

        XCTAssertEqual(variation?[1].moveNumber, 3)
        XCTAssertEqual(variation?[1].white!.move, "d3")
        XCTAssertEqual(variation?[1].white!.variations.count, 0)
        XCTAssertEqual(variation?[1].black!.move, "d6")
        XCTAssertEqual(variation?[1].black!.variations.count, 0)

        XCTAssertEqual(variation?[0].black?.variations.count, 1)
        let subVariation = variation?[0].black?.variations["d6"]
        XCTAssertEqual(subVariation?[0].moveNumber, 2)
        XCTAssertNil(subVariation?[0].white)
        XCTAssertEqual(subVariation?[0].black!.move, "d6")
        XCTAssertEqual(subVariation?[0].black!.variations.count, 0)
        XCTAssertEqual(subVariation?[1].moveNumber, 3)
        XCTAssertEqual(subVariation?[1].white!.move, "d3")
        XCTAssertEqual(subVariation?[1].white!.variations.count, 0)
        XCTAssertNil(subVariation?[1].black)
    }
    
    func testMoveHistory() throws {
        let game = PgnGameParser.parse("1. e4 e5 2. Nc3 Nf6")
        let containers = ContainerFactory.create(game)
        
        let testee = try XCTUnwrap(testee)
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

    }
}
