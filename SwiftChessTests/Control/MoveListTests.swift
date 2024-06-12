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
            try assertMove(move)
        }
        
        let testee = try XCTUnwrap(testee)
        testee.start()
        XCTAssertNil(testee.currentMove)
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
    
    private func assertMove(
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
        let moveToCompare = move.getPiece().getColor() == .white ? rowContainer.white.move : rowContainer.black?.move
        
        moves?.append(moveString)
        boardCache = try XCTUnwrap(Pgn.loadPosition(try XCTUnwrap(moves)))
        
        guard testee.currentMove?.move != move || moveToCompare != move else {
            return
        }

        XCTFail(message(moveString), file: file, line: line)
    }
}
