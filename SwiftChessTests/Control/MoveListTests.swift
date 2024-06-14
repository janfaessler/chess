import XCTest
import SwiftChess

final class MoveListTests: XCTestCase {

    var testee:MoveListModel?
    var boardCache:Position?
    var moves:[any StringProtocol]?
    
    override func setUpWithError() throws {
        testee = MoveListModel()
        boardCache = Fen.loadStartingPosition()
        moves = []
    }

    func testTopLevelMoveNavigation() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            try playAndAssertMove(move)
        }
        
        let testee = try XCTUnwrap(testee)
        testee.start()
        XCTAssertTrue(testee.isCurrentMove(nil))
        for move in testMoves {
            testee.forward()
            XCTAssertEqual(testee.currentMove?.move.info(), move)
        }
        
        testee.start()
        testee.end()
        
        for move in testMoves.reversed() {
            XCTAssertEqual(testee.currentMove?.move.info(), move)
            testee.back()
        }
        XCTAssertNil(testee.currentMove)
    }
    
    func testMoveVariationOnBlack() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            try playAndAssertMove(move)
        }
        
        let testee = try XCTUnwrap(testee)
        testee.back()
        XCTAssertEqual(testee.currentMove?.move.info(), "Nc3")
        testee.back()
        XCTAssertEqual(testee.currentMove?.move.info(), "e5")
        
        let moveBc4 = try createMove("Bc4", previousMoves: ["e4", "e5"])
        testee.movePlayed(moveBc4)
        XCTAssertEqual(testee.currentMove?.move.info(), "Bc4")

        let moveBc5 = try createMove("Bc5", previousMoves: ["e4", "e5", "Bc4"])
        testee.movePlayed(moveBc5)
        XCTAssertEqual(testee.currentMove?.move, moveBc5)

        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        testee.forward()
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        
        let moveD3 = try createMove("d3", previousMoves: ["e4", "e5", "Bc4", "Bc5"])
        testee.movePlayed(moveD3)
        XCTAssertEqual(testee.currentMove?.move, moveD3)
        
        let moveD6 = try createMove("d6", previousMoves: ["e4", "e5", "Bc4", "Bc5", "d3"])
        testee.movePlayed(moveD6)
        XCTAssertEqual(testee.currentMove?.move, moveD6)
        
        let variation = testee.moves[0].black?.variations["Bc4"]
        XCTAssertEqual(variation?[0].moveNumber, 1)
        XCTAssertEqual(variation?[0].white!.move, moveBc4)
        XCTAssertEqual(variation?[0].white!.variations.count, 0)
        XCTAssertEqual(variation?[0].black!.move, moveBc5)
        XCTAssertEqual(variation?[0].black!.variations.count, 0)
        XCTAssertEqual(variation?[1].moveNumber, 2)
        XCTAssertEqual(variation?[1].white!.move, moveD3)
        XCTAssertEqual(variation?[1].white!.variations.count, 0)
        XCTAssertEqual(variation?[1].black!.move, moveD6)
        XCTAssertEqual(variation?[1].black!.variations.count, 0)

    }
    
    func testMoveVariationOnWhite() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            try playAndAssertMove(move)
        }
        
        let testee = try XCTUnwrap(testee)
        testee.back()
        XCTAssertEqual(testee.currentMove?.move.info(), "Nc3")
        
        let moveBc5 = try createMove("Bc5", previousMoves: ["e4", "e5", "Nc3"])
        testee.movePlayed(moveBc5)
        XCTAssertEqual(testee.currentMove?.move, moveBc5)

        let moveBc4 = try createMove("Bc4", previousMoves: ["e4", "e5", "Nc3", "Bc5"])
        testee.movePlayed(moveBc4)
        XCTAssertEqual(testee.currentMove?.move, moveBc4)

        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        testee.forward()
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        
        let moveD6 = try createMove("d6", previousMoves: ["e4", "e5", "Nc3", "Bc5", "Bc4"])
        testee.movePlayed(moveD6)
        XCTAssertEqual(testee.currentMove?.move, moveD6)
        
        let moveD3 = try createMove("d3", previousMoves: ["e4", "e5", "Nc3", "Bc5", "Bc4", "d6"])
        testee.movePlayed(moveD3)
        XCTAssertEqual(testee.currentMove?.move, moveD3)
        
        testee.back()
        testee.movePlayed(moveD3)
        XCTAssertEqual(testee.currentMove?.move, moveD3)
        
        let variation = testee.moves[1].white?.variations["Bc5"]
        XCTAssertEqual(variation?[0].moveNumber, 1)
        XCTAssertNil(variation?[0].white)
        XCTAssertEqual(variation?[0].black!.move, moveBc5)
        XCTAssertEqual(variation?[0].black!.variations.count, 0)
        XCTAssertEqual(variation?[1].moveNumber, 2)
        XCTAssertEqual(variation?[1].white!.move, moveBc4)
        XCTAssertEqual(variation?[1].white!.variations.count, 0)
        XCTAssertEqual(variation?[1].black!.move, moveD6)
        XCTAssertEqual(variation?[1].black!.variations.count, 0)
        XCTAssertEqual(variation?[2].moveNumber, 3)
        XCTAssertEqual(variation?[2].white!.move, moveD3)
        XCTAssertEqual(variation?[2].white!.variations.count, 0)
        XCTAssertNil(variation?[2].black)
    }
    
    func testGoToMoveWithTwoVariations() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            try playAndAssertMove(move)
        }
        let testee = try XCTUnwrap(testee)
        let variationStart = try XCTUnwrap(testee.moves[0].black)
        testee.goToMove(variationStart)
        XCTAssertEqual(testee.currentMove?.move, variationStart.move)
        
        let moveBc4 = try createMove("Bc4", previousMoves: testMoves)
        testee.movePlayed(moveBc4)
        XCTAssertEqual(testee.currentMove?.move, moveBc4)

        let moveBc5 = try createMove("Bc5", previousMoves: ["e4", "e5", "Bc4"])
        testee.movePlayed(moveBc5)
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        
        testee.goToMove(variationStart)
        XCTAssertEqual(testee.currentMove?.move, variationStart.move)

        let moveD3 = try createMove("d3", previousMoves: ["e4", "e5"])
        testee.movePlayed(moveD3)
        XCTAssertEqual(testee.currentMove?.move, moveD3)
        
        let moveD6 = try createMove("d6", previousMoves: ["e4", "e5", "d3"])
        testee.movePlayed(moveD6)
        XCTAssertEqual(testee.currentMove?.move, moveD6)
        
        testee.goToMove(try XCTUnwrap(testee.moves[0].black?.variations["Bc4"]?[0].white))
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        
        XCTAssertEqual(testee.moves[0].black?.variations.count, 2)
        let variationD3 = testee.moves[0].black?.variations["d3"]
        XCTAssertEqual(variationD3?[0].white!.move, moveD3)
        XCTAssertEqual(variationD3?[0].white!.variations.count, 0)
        XCTAssertEqual(variationD3?[0].black!.move, moveD6)
        XCTAssertEqual(variationD3?[0].black!.variations.count, 0)

        let variationBc4 = testee.moves[0].black?.variations["Bc4"]
        XCTAssertEqual(variationBc4?[0].white!.move, moveBc4)
        XCTAssertEqual(variationBc4?[0].white!.variations.count, 0)
        XCTAssertEqual(variationBc4?[0].black!.move, moveBc5)
        XCTAssertEqual(variationBc4?[0].black!.variations.count, 0)

    }
    
    func testSubVariationBlackOnWhite() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            try playAndAssertMove(move)
        }
        
        let testee = try XCTUnwrap(testee)
        testee.back()
        XCTAssertEqual(testee.currentMove?.move.info(), "Nc3")
        
        let moveBc5 = try createMove("Bc5", previousMoves: ["e4", "e5", "Nc3"])
        testee.movePlayed(moveBc5)
        XCTAssertEqual(testee.currentMove?.move, moveBc5)

        let moveBc4 = try createMove("Bc4", previousMoves: ["e4", "e5", "Nc3", "Bc5"])
        testee.movePlayed(moveBc4)
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        
        let moveD6 = try createMove("d6", previousMoves: ["e4", "e5", "Nc3", "Bc5", "Bc4"])
        testee.movePlayed(moveD6)
        XCTAssertEqual(testee.currentMove?.move, moveD6)
        
        let moveD3 = try createMove("d3", previousMoves: ["e4", "e5", "Nc3", "Bc5", "Bc4", "d6"])
        testee.movePlayed(moveD3)
        XCTAssertEqual(testee.currentMove?.move, moveD3)
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveD6)
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        
        let subMoveD3 = try createMove("d3", previousMoves: ["e4", "e5", "Nc3", "Bc5"])
        testee.movePlayed(subMoveD3)
        XCTAssertEqual(testee.currentMove?.move, subMoveD3)
        
        let subMoveD6 = try createMove("d6", previousMoves: ["e4", "e5", "Nc3", "Bc5", "d3"])
        testee.movePlayed(subMoveD6)
        XCTAssertEqual(testee.currentMove?.move, subMoveD6)
        
        let subMoveBe2 = try createMove("Be2", previousMoves: ["e4", "e5", "Nc3", "Bc5", "d3", "d6"])
        testee.movePlayed(subMoveBe2)
        XCTAssertEqual(testee.currentMove?.move, subMoveBe2)
        
        XCTAssertEqual(testee.moves[1].white?.variations.count, 1)
        let variation = testee.moves[1].white?.variations["Bc5"]
        XCTAssertEqual(variation?[0].moveNumber, 1)
        XCTAssertEqual(variation?[0].black!.move, moveBc5)
        XCTAssertEqual(variation?[0].black!.variations.count, 1)
        XCTAssertEqual(variation?[1].moveNumber, 2)
        XCTAssertEqual(variation?[1].white!.move, moveBc4)
        XCTAssertEqual(variation?[1].white!.variations.count, 0)
        XCTAssertEqual(variation?[1].black!.move, moveD6)
        XCTAssertEqual(variation?[1].black!.variations.count, 0)

        XCTAssertEqual(variation?[2].moveNumber, 3)
        XCTAssertEqual(variation?[2].white!.move, moveD3)
        XCTAssertEqual(variation?[2].white!.variations.count, 0)

        let subVariation = variation?[0].black?.variations["d3"]
        XCTAssertEqual(subVariation?[0].moveNumber, 1)
        XCTAssertEqual(subVariation?[0].white!.move, subMoveD3)
        XCTAssertEqual(subVariation?[0].white!.variations.count, 0)
        XCTAssertEqual(subVariation?[0].black!.move, subMoveD6)
        XCTAssertEqual(subVariation?[0].black!.variations.count, 0)

        XCTAssertEqual(subVariation?[1].moveNumber, 2)
        XCTAssertEqual(subVariation?[1].white!.move, subMoveBe2)
        XCTAssertEqual(subVariation?[1].white!.variations.count, 0)
        XCTAssertNil(subVariation?[1].black)

    }
    
    func testSubVariationWhiteOnBlack() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            try playAndAssertMove(move)
        }
        
        let testee = try XCTUnwrap(testee)
        testee.back()
        XCTAssertEqual(testee.currentMove?.move.info(), "Nc3")
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move.info(), "e5")
        
        
        let moveBc4 = try createMove("Bc4", previousMoves: ["e4", "e5"])
        testee.movePlayed(moveBc4)
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        
        let moveBc5 = try createMove("Bc5", previousMoves: ["e4", "e5", "Bc4"])
        testee.movePlayed(moveBc5)
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        
        let moveD3 = try createMove("d3", previousMoves: ["e4", "e5", "Bc4", "Bc5"])
        testee.movePlayed(moveD3)
        XCTAssertEqual(testee.currentMove?.move, moveD3)
        
        let moveD6 = try createMove("d6", previousMoves: ["e4", "e5", "Bc4", "Bc5", "d3"])
        testee.movePlayed(moveD6)
        XCTAssertEqual(testee.currentMove?.move, moveD6)

        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveD3)
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        
        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        
        
        let subMoveD6 = try createMove("d6", previousMoves: ["e4", "e5", "Bc4"])
        testee.movePlayed(subMoveD6)
        XCTAssertEqual(testee.currentMove?.move, subMoveD6)
                                                          
        let subMoveD3 = try createMove("d3", previousMoves: ["e4", "e5", "Bc4","d6"])
        testee.movePlayed(subMoveD3)
        XCTAssertEqual(testee.currentMove?.move, subMoveD3)
        
        
        XCTAssertEqual(testee.moves[0].black!.variations.count, 1)
        let variation = testee.moves[0].black?.variations["Bc4"]
        XCTAssertEqual(variation?[0].moveNumber, 1)
        XCTAssertEqual(variation?[0].white!.move, moveBc4)
        XCTAssertEqual(variation?[0].white!.variations.count, 1)
        XCTAssertEqual(variation?[0].black!.move, moveBc5)
        XCTAssertEqual(variation?[0].black!.variations.count, 0)

        XCTAssertEqual(variation?[1].moveNumber, 2)
        XCTAssertEqual(variation?[1].white!.move, moveD3)
        XCTAssertEqual(variation?[1].white!.variations.count, 0)
        XCTAssertEqual(variation?[1].black!.move, moveD6)
        XCTAssertEqual(variation?[1].black!.variations.count, 0)

        XCTAssertEqual(variation?[0].white?.variations.count, 1)
        let subVariation = variation?[0].white?.variations["d6"]
        XCTAssertEqual(subVariation?[0].moveNumber, 1)
        XCTAssertNil(subVariation?[0].white)
        XCTAssertEqual(subVariation?[0].black!.move, subMoveD6)
        XCTAssertEqual(subVariation?[0].black!.variations.count, 0)
        XCTAssertEqual(subVariation?[1].moveNumber, 2)
        XCTAssertEqual(subVariation?[1].white!.move, subMoveD3)
        XCTAssertEqual(subVariation?[1].white!.variations.count, 0)
        XCTAssertNil(subVariation?[1].black)
    }
    
    private func createMove(_ notation:String, previousMoves:[String]) throws -> Move  {
        let position = try XCTUnwrap(Pgn.loadPosition(previousMoves))
        let move = try XCTUnwrap(MoveFactory.create(notation, position: try XCTUnwrap(position)))
        return move
    }
    
    private func playAndAssertMove(
        _ moveString:String,
        message: (String) -> String = { "eror with move \($0)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let cache = try XCTUnwrap(boardCache)
        let move = try XCTUnwrap(MoveFactory.create(moveString, position: cache))
        
        testee.movePlayed(move)
        
        let rowContainer = try XCTUnwrap(testee.moves.last)
        let moveToCompare = move.getPiece().getColor() == .white ? rowContainer.white?.move : rowContainer.black?.move
        
        moves?.append(moveString)
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(moves)))
        
        guard testee.currentMove?.move != move || moveToCompare != move else {
            return
        }

        XCTFail(message(moveString), file: file, line: line)
    }
}
