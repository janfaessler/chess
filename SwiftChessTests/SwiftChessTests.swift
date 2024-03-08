//
//  SwiftChessTests.swift
//  SwiftChessTests
//
//  Created by Jan Fässler on 06.03.2024.
//
import XCTest
import SwiftChess

final class SwiftChessTests: SwiftChessTestBase {
    
    func testStartingPosition() throws {
        let testee = try XCTUnwrap(testee)
        let figures = testee.getFigures()
        
        for color:PieceColor in [.white, .black] {
            let row = color == .white ? 1 : 8
            assertFigureExists(Rook("a\(row)", color: color)!)
            assertFigureExists(Knight("b\(row)", color: color)!)
            assertFigureExists(Bishop("c\(row)", color: color)!)
            assertFigureExists(Queen("d\(row)", color: color)!)
            assertFigureExists(King("e\(row)", color: color)!)
            assertFigureExists(Bishop("f\(row)", color: color)!)
            assertFigureExists(Knight("g\(row)", color: color)!)
            assertFigureExists(Rook("h\(row)", color: color)!)

            let pawnRow = color == .white ? 2 : 7
            for file in 1...8 {
                XCTAssert(figures.contains([Pawn(color: color, row: pawnRow, file: file)]))
            }
        }
    }
    
    func testSimplePawnCapture() throws {
        
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("d7", to: "d5", type:.pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e4", to: "d5", type:.pawn, color: .white)
        
    }
    
    
    func testEnPassan() throws {
        
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("a7", to: "a6", type:.pawn, color: .black)
        
        try moveAndAssert("e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert("d7", to: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e5", to: "d6", type: .pawn, color: .white)
        
    }
    
    func testEnPassantToPromotion() throws {
        
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("a7", to: "a6", type:.pawn, color: .black)
        
        try moveAndAssert("e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert("d7", to: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e5", to: "d6", type: .pawn, color: .white)
        try moveAndAssert("b7", to: "b5", type:.pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("d6", to: "e7", type: .pawn, color: .white)
        try moveAndAssert("c7", to: "c5", type:.pawn, color: .black, moveType: .Double)

        try captureAndAssert("e7", to: "d8", type: .pawn, color: .white)
        
    }
    
    func testSimpleCastle() throws {
    
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("e7", to: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssert("f1", to: "c4", type:.bishop, color: .white)
        try moveAndAssert("f8", to: "c5", type:.bishop, color: .black)
        
        try moveAndAssert("g1", to: "f3", type:.knight, color: .white)
        try moveAndAssert("g8", to: "f6", type:.knight, color: .black)
        
        try moveAndAssert("e1", to: "g1", type:.king, color: .white, moveType: .Castle)
        try moveAndAssert("e8", to: "g8", type:.king, color: .black, moveType: .Castle)
        
    }
    
    func testSimpleCastleWithTryingWrongMoves() throws {
    
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("e7", to: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssertError("f1", to: "c5", type: .bishop, color: .white)
        
        try moveAndAssert("f1", to: "c4", type:.bishop, color: .white)
        try moveAndAssert("f8", to: "b4", type:.bishop, color: .black)
        
        try moveAndAssertError("d2", to: "d3", type: .pawn, color: .white)
        try moveAndAssertError("d2", to: "d4", type: .pawn, color: .white, moveType: .Double)
        
        try moveAndAssert("c2", to: "c3", type:.pawn, color: .white)
        try moveAndAssert("g8", to: "f6", type:.knight, color: .black)
        
        try moveAndAssert("g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert("e8", to: "g8", type:.king, color: .black, moveType: .Castle)
        
        try captureAndAssert("c3", to: "b4", type: .pawn, color: .white)
        try moveAndAssert("f8", to: "e8", type: .rook, color: .black)
        
        try moveAndAssert("e1", to: "g1", type:.king, color: .white, moveType: .Castle)
        try moveAndAssert("g8", to: "h8", type: .king, color: .black)
        
        try moveAndAssert("g1", to: "h1", type: .king, color: .white)
        
        try moveAndAssertError(Move(8, 9,piece: King("h8", color: .black)!, type: MoveType.Normal))
        
        let testee = try XCTUnwrap(testee)
        XCTAssertThrowsError(try testee.move(Move(8,9, piece: King("h8", color: .black)!, type: .Normal)))
        XCTAssertFalse(figureExist(King(color: .black, row: 8, file: 9)))
    }
}
