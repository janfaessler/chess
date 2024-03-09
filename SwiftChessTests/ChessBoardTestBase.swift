//
//  ChessBoardTestBase.swift
//  SwiftChessTests
//
//  Created by Jan Fässler on 07.03.2024.
//

import XCTest
import SwiftChess

class SwiftChessTestBase: XCTestCase {
    
    var testee:ChessBoard?

    override func setUpWithError() throws {
        testee = ChessBoard(Fen.loadStartingPosition())
    }

    func moveAndAssert(
        _ from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        moveType:MoveType = .Normal,
        message: (String, String, ChessFigure) -> String = { "\($2.getColor()) \($2.getType()) could not move from \($0) to \($1)" },
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
        let startFigureExists = figureExist(startFigure)
        let endFigureExists = figureExist(endFigure)
        
        guard moveError == true || startFigureExists == true || endFigureExists == false || testee.getFigures().count != pieceCount else {
            return
        }
        
        XCTFail(message(from, to, startFigure), file: file, line: line)

    }
    
    func moveAndAssertError(
        _ from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        moveType:MoveType = .Normal,
        message: (String, String, ChessFigure) -> String = { "move from \($0) to \($1) of \($2.getColor()) \($2.getType()) should not be possible" },
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
        message: (Move, ChessFigure) -> String = { "move from \($0.getPiece().getFieldInfo()) to \($0.getField()) of \($1.getColor()) \($1.getType()) should not be possible" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        
        do {
            try testee.move(move)
        } catch { return }
        
        XCTFail(message(move, move.getPiece()), file: file, line: line)
        
    }
    
    func captureAndAssert(
        _ from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        message: (String, String, ChessFigure) -> String = { "\($2.getColor()) \($2.getType()) on \($0) could not capture on \($1)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let pieceCount = testee.getFigures().count - 1
        let startFigure = Figure.create(from, type:type, color: color)!
        let endFigure = Figure.create(to, type:type, color:color)!
        let move = Move(to, piece:startFigure, type: .Normal)!
        var moveError:Bool = false

        do {
            try testee.move(move)
        } catch { moveError = true}
        
        guard moveError == true || figureExist(startFigure) == true || figureExist(endFigure) == false || testee.getFigures().count != pieceCount else {
            return
        }

        XCTFail(message(from, to, startFigure), file: file, line: line)
    }
    
    func captureAndAssertError(
        _ from:String,
        to:String,
        type:PieceType,
        color:PieceColor,
        message: (String, String, ChessFigure) -> String = { "\($2.getColor()) \($2.getType()) on \($0) could not capture on \($1)" },
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
        message: (String, String, ChessFigure) -> String = { "\($2.getColor()) \($2.getType()) on \($0) could not capture on \($1)" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let testee = try XCTUnwrap(testee)
        let pieceCount = testee.getFigures().count - 1
        let startFigure = Figure.create(from, type:type, color: color)!
        let endFigure = Figure.create(to, type:.queen, color:color)!
        let move = Move(to, piece:startFigure, type: .Normal)!
        var moveError:Bool = false

        do {
            try testee.move(move)
        } catch { moveError = true}
        
        guard moveError == true || figureExist(startFigure) == true || figureExist(endFigure) == false || testee.getFigures().count != pieceCount else {
            return
        }

        XCTFail(message(from, to, startFigure), file: file, line: line)
    }

    func assertFigureExists(
        _ f: ChessFigure,
        message: (ChessFigure) -> String = { "\($0.info()) does not exist" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard figureExist(f) == false else { return }
        XCTFail(message(f), file: file, line: line)
    }
    
    func assertFigureNotExists(
        _ f: ChessFigure,
        message: (ChessFigure) -> String = { "\($0.info()) does not exist" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard figureExist(f) == true else { return }
        XCTFail(message(f), file: file, line: line)
    }
    
    func assertMoves(
        _ expectedMoves:[String],
        message: ([String], [String]) -> String = { "[\($0.joined(separator: ","))] is not equal [\($1.joined(separator: ","))]" },
        file: StaticString = #filePath,
        line: UInt = #line) throws {
        let testee = try XCTUnwrap(testee)
        let moves = testee.getMoves().map({$0.info()})
        
        guard !moves.elementsEqual(expectedMoves) else { return }

        XCTFail(message(moves, expectedMoves), file: file, line: line)
    }
    
    func figureExist(_ figure: ChessFigure) -> Bool {
        do {
            let testee = try XCTUnwrap(testee)
            return testee.getFigures().contains(where: { $0.equals(figure) })
        } catch {
            return false
        }
    }
}
