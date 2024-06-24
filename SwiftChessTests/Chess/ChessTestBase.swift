import XCTest
import SwiftChess

class ChessTestBase: XCTestCase {
    
    var testee:ChessBoard?
    var moveLog:[String] = []

    override func setUpWithError() throws {
        testee = ChessBoard(PositionFactory.startingPosition())
        moveLog = []
    }

    func moveAndAssert(
        from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        moveType:MoveType = .Normal,
        message: (String, String, any ChessFigure) -> String = { "\($2.getColor()) \($2.getType()) could not move from \($0) to \($1)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let pieceCount = testee.getFigures().count
        let startFigure = Figure.create(from, type:type, color: color)!
        let endFigure = Figure.create(to, type:type, color:color, moved: true)!
        let move = Move(to, piece:startFigure, type: moveType)!
        var moveError:Bool = false
        do {
            try testee.move(move)
        } catch { moveError = true }
        let startFigureExists = figureExist(startFigure, testee: testee)
        let endFigureExists = figureExist(endFigure, testee: testee)
        let nextColorToMoveDidNotChange = testee.getColorToMove() == color
        
        guard moveError == true || startFigureExists == true || endFigureExists == false || testee.getFigures().count != pieceCount && nextColorToMoveDidNotChange else {
            return
        }
        
        XCTFail(message(from, to, startFigure), file: file, line: line)

    }
    
    func moveAndAssert(
        notation:String,
        toField:String,
        type:PieceType,
        color:PieceColor,
        moveType:MoveType = .Normal,
        message: (String, String, any ChessFigure) -> String = { "\($0): \($2.getColor()) \($2.getType()) could not move to \($1)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let pieceCount = testee.getFigures().count
        let cache = testee.getPosition()
        guard let move = MoveFactory.create(notation, position: cache) else {
            XCTFail("move \(notation) could not be created", file: file, line: line)
            return
        }
        
        let endFigure = Figure.create(toField, type:type, color:color, moved: true)!
        var moveError:Bool = false
        do {
            try testee.move(move)
            moveLog += [notation]
        } catch { moveError = true }
        let endFigureExists = figureExist(endFigure, testee: testee)
        let nextColorToMoveDidNotChange = testee.getColorToMove() == color
        
        guard moveError == true,
              endFigureExists == false,
              testee.getFigures().count != pieceCount && nextColorToMoveDidNotChange else {
            return
        }
        
        XCTFail(message(notation, toField, endFigure), file: file, line: line)

    }
    
    func moveAndAssertError(
        _ from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        moveType:MoveType = .Normal,
        message: (String, String, any ChessFigure) -> String = { "move from \($0) to \($1) of \($2.getColor()) \($2.getType()) should not be possible" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let startFigure = Figure.create(from, type:type, color: color)!
        let move = Move(to, piece:startFigure, type: moveType)!
        
        do {
            try testee.move(move)
        } catch { return }
        
        XCTFail(message(from, to, startFigure), file: file, line: line)
    }
    
    func moveAndAssertError(
         _ move:Move,
         message: (Move, any ChessFigure) -> String = { "move from \($0.getPiece().getFieldInfo()) to \($0.getField()) of \($1.getColor()) \($1.getType()) should not be possible" },
         file: StaticString = #filePath,
         line: UInt = #line
     ) throws {
         let testee = try XCTUnwrap(testee)
         
         do {
             try testee.move(move)
         } catch { return }
         
         XCTFail(message(move, move.getPiece()), file: file, line: line)
         
     }
    
    func moveAndAssertError(
        _ notation:String,
        message: (String) -> String = { "move \($0) should not be possible" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        
        do {
            try testee.move(notation)
        } catch { return }
        
        XCTFail(message(notation), file: file, line: line)
        
    }
    
    func captureAndAssert(
        _ from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        message: (String, String, any ChessFigure) -> String = { "\($2.getColor()) \($2.getType()) on \($0) could not capture on \($1)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let pieceCount = testee.getFigures().count - 1
        let startFigure = Figure.create(from, type:type, color: color)!
        let endFigure = Figure.create(to, type:type, color:color)!
        let move = Move(to, piece:startFigure, type: .Normal)!
        let nextColorToMoveDidNotChange = testee.getColorToMove() == color

        var moveError:Bool = false

        do {
            try testee.move(move)
        } catch { moveError = true}
        
        guard moveError == true || figureExist(startFigure, testee: testee) == true || figureExist(endFigure, testee: testee) == false || testee.getFigures().count != pieceCount && nextColorToMoveDidNotChange else {
            return
        }

        XCTFail(message(from, to, startFigure), file: file, line: line)
    }
    
    func captureAndAssertError(
        _ from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        message: (String, String, any ChessFigure) -> String = { "\($2.getColor()) \($2.getType()) on \($0) could not capture on \($1)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let startFigure = Figure.create(from, type:type, color: color)!
        let move = Move(to, piece:startFigure, type: .Normal)!

        do {
            try testee.move(move)
        } catch { return }

        XCTFail(message(from, to, startFigure), file: file, line: line)
    }
    
    func captureAndAssertPromotion(
        _ from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        message: (String, String, any ChessFigure) -> String = { "\($2.getColor()) \($2.getType()) on \($0) could not capture on \($1)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let pieceCount = testee.getFigures().count - 1
        let startFigure = Figure.create(from, type:type, color: color)!
        let endFigure = Figure.create(to, type:.queen, color:color)!
        let move = Move(to, piece:startFigure, type: .Promotion)!
        let nextColorToMoveDidNotChange = testee.getColorToMove() == color
        var moveError:Bool = false

        do {
            try testee.move(move)
        } catch { moveError = true}
        
        guard moveError == true,
              figureExist(startFigure, testee: testee) == true,
              figureExist(endFigure, testee: testee) == false,
              testee.getFigures().count != pieceCount && nextColorToMoveDidNotChange else {
            return
        }

        XCTFail(message(from, to, startFigure), file: file, line: line)
    }
    
    func assertPossibleMoves(
        forFigure:any ChessFigure,
        moves:[Move],
        message: ([String], [String]) -> String = { "moves [\($0)] and [\($1)] are not equal" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        
        let testee = try XCTUnwrap(testee)
        let blackKing = testee.getFigures().first(where: { $0.equals(forFigure)})!
        let possibleMoves = testee.getPossibleMoves(forPeace: blackKing)
            
        guard possibleMoves.elementsEqual(moves) == false else {
            return
        }
            
        XCTFail(message(possibleMoves.map({$0.info()}), moves.map({$0.info()})), file: file, line: line)
    }

    func assertFigureExists(
        _ f: any ChessFigure,
        message: (any ChessFigure) -> String = { "\($0.info()) does not exist" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard figureExist(f, testee: try! XCTUnwrap(testee)) == false else { return }
        XCTFail(message(f), file: file, line: line)
    }
    
    func assertFigureNotExists(
        _ f: any ChessFigure,
        message: (any ChessFigure) -> String = { "\($0.info()) does not exist" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard figureExist(f, testee: try! XCTUnwrap(testee)) == true else { return }
        XCTFail(message(f), file: file, line: line)
    }
    
    func assertMoves(
        _ expectedMoves:[String],
        message: ([String], [String]) -> String = { "[\($0.joined(separator: ","))] is not equal [\($1.joined(separator: ","))]" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let moves = testee.getMoveLog()
        
        guard !moves.elementsEqual(expectedMoves) else { return }

        XCTFail(message(moves, expectedMoves), file: file, line: line)
    }
    
    func assertMoves(
        message: ([String], [String]) -> String = { "[\($0.joined(separator: ","))] is not equal [\($1.joined(separator: ","))]" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let moves = testee.getMoveLog()
        
        guard !moves.elementsEqual(moveLog) else { return }

        XCTFail(message(moves, moveLog), file: file, line: line)
    }
    
    func assertGameState(
        _ expectedState:GameState,
        fen:String = "",
        message: (GameState, GameState, String) -> String = { "\($0) is not equal to \($1). Fen: \($2)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        
        let gameState = testee.getGameState()
        guard gameState != expectedState else { return }
        
        XCTFail(message(gameState, expectedState, fen), file: file, line: line)
    }
    
    func figureExist(_ figure:any ChessFigure, testee:ChessBoard) -> Bool {
        testee.getFigures().contains(where: { $0.equals(figure) })
    }
    
    func loadFen(_ fen:String) {
        testee = ChessBoard(PositionFactory.loadPosition(fen))
    }
}
