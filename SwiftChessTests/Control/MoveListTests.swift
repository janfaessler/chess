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
        
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5"])))
        let moveBc4 = try XCTUnwrap(MoveFactory.create("Bc4", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveBc4)
        XCTAssertEqual(testee.currentMove?.move.info(), "Bc4")
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].white!.move, moveBc4)

        
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5", "Bc4"])))
        let moveBc5 = try XCTUnwrap(MoveFactory.create("Bc5", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveBc5)
        XCTAssertEqual(testee.currentMove?.move.info(), "Bc5")
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].white!.move, moveBc4)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].black!.move, moveBc5)

        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        testee.forward()
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5", "Bc4", "Bc5"])))
        let moveD3 = try XCTUnwrap(MoveFactory.create("d3", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveD3)
        XCTAssertEqual(testee.currentMove?.move.info(), "d3")
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].moveNumber, 1)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].white!.move, moveBc4)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].black!.move, moveBc5)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[1].moveNumber, 2)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[1].white!.move, moveD3)
        
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5", "Bc4", "Bc5", "d3"])))
        let moveD6 = try XCTUnwrap(MoveFactory.create("d6", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveD6)
        XCTAssertEqual(testee.currentMove?.move.info(), "d6")
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].moveNumber, 1)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].white!.move, moveBc4)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].black!.move, moveBc5)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[1].moveNumber, 2)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[1].white!.move, moveD3)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[1].black!.move, moveD6)
    }
    
    func testMoveVariationOnWhite() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            try playAndAssertMove(move)
        }
        
        let testee = try XCTUnwrap(testee)
        testee.back()
        XCTAssertEqual(testee.currentMove?.move.info(), "Nc3")
        
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5", "Nc3"])))
        let moveBc5 = try XCTUnwrap(MoveFactory.create("Bc5", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveBc5)
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        XCTAssertEqual(testee.moves[1].white!.variations["Bc5"]?[0].black!.move, moveBc5)

        
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5", "Nc3", "Bc5"])))
        let moveBc4 = try XCTUnwrap(MoveFactory.create("Bc4", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveBc4)
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        XCTAssertEqual(testee.moves[1].white!.variations["Bc5"]?[0].black!.move, moveBc5)
        XCTAssertEqual(testee.moves[1].white!.variations["Bc5"]?[1].white!.move, moveBc4)

        testee.back()
        XCTAssertEqual(testee.currentMove?.move, moveBc5)
        testee.forward()
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
    }
    
    func testGoToMoveWithTwoVariations() throws {
        let testMoves = ["e4", "e5", "Nc3", "Nc6"]
        
        for move in testMoves {
            try playAndAssertMove(move)
        }
        let testee = try XCTUnwrap(testee)
        let variationStart = try XCTUnwrap(testee.moves[0].black)
        testee.goToMove(variationStart)
        XCTAssertEqual(testee.currentMove?.move.info(), "e5")
        
        let moveBc4 = try XCTUnwrap(MoveFactory.create("Bc4", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveBc4)
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].white!.move, moveBc4)

        
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5", "Bc4"])))
        let moveBc5 = try XCTUnwrap(MoveFactory.create("Bc5", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveBc5)
        XCTAssertEqual(testee.currentMove?.move.info(), "Bc5")
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].white!.move, moveBc4)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].black!.move, moveBc5)
        
        testee.goToMove(variationStart)
        XCTAssertEqual(testee.currentMove?.move.info(), "e5")

        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5"])))
        let moveD3 = try XCTUnwrap(MoveFactory.create("d3", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveD3)
        XCTAssertEqual(testee.currentMove?.move, moveD3)
        XCTAssertEqual(testee.moves[0].black?.variations["d3"]?[0].white!.move, moveD3)

        
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(["e4", "e5", "d3"])))
        let moveD6 = try XCTUnwrap(MoveFactory.create("d6", position: try XCTUnwrap(boardCache)))
        testee.movePlayed(moveD6)
        XCTAssertEqual(testee.currentMove?.move, moveD6)
        XCTAssertEqual(testee.moves[0].black?.variations["d3"]?[0].white!.move, moveD3)
        XCTAssertEqual(testee.moves[0].black?.variations["d3"]?[0].black!.move, moveD6)
        
        
        testee.goToMove(try XCTUnwrap(testee.moves[0].black?.variations["Bc4"]?[0].white))
        XCTAssertEqual(testee.currentMove?.move, moveBc4)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].white!.move, moveBc4)
        XCTAssertEqual(testee.moves[0].black?.variations["Bc4"]?[0].black!.move, moveBc5)

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
