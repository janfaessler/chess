//
//  SwiftChessTests.swift
//  SwiftChessTests
//
//  Created by Jan Fässler on 06.03.2024.
//
import XCTest
import SwiftChess

final class StartingPositionTests: SwiftChessTestBase {
    
    func testStartingPosition() throws {
        for color:PieceColor in [.white, .black] {
            let row = color == .white ? 1 : 8
            assertFigureExists(Figure.create("a\(row)", type: .rook, color: color)!)
            assertFigureExists(Figure.create("b\(row)", type: .knight, color: color)!)
            assertFigureExists(Figure.create("c\(row)", type: .bishop, color: color)!)
            assertFigureExists(Figure.create("d\(row)", type: .queen, color: color)!)
            assertFigureExists(Figure.create("e\(row)", type: .king, color: color)!)
            assertFigureExists(Figure.create("f\(row)", type: .bishop, color: color)!)
            assertFigureExists(Figure.create("g\(row)", type: .knight, color: color)!)
            assertFigureExists(Figure.create("h\(row)", type: .rook, color: color)!)

            let pawnRow = color == .white ? 2 : 7
            for file in 1...8 {
                assertFigureExists(Figure.create(type: .pawn, color: color, row:pawnRow, file: file))
            }
        }
    }
    

    
    func testSimplePawnCapture() throws {
        
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("d7", to: "d5", type:.pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e4", to: "d5", type:.pawn, color: .white)
        
        try assertMoves(["e4", "d5", "d5"])
        
    }
    
    
    func testEnPassantLeft() throws {
        
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("a7", to: "a6", type:.pawn, color: .black)
        
        try moveAndAssert("e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert("d7", to: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e5", to: "d6", type: .pawn, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "d5", "d6"])

        
    }
    
    func testEnPassanRight() throws {
        
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("a7", to: "a6", type:.pawn, color: .black)
        
        try moveAndAssert("e4", to: "e5", type: .pawn, color: .white)
        try moveAndAssert("f7", to: "f5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("e5", to: "f6", type: .pawn, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "f5", "f6"])
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

        try captureAndAssertPromotion("e7", to: "d8", type: .pawn, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "d5", "d6", "b5", "e7", "c5", "d8"])

    }
    
    func testShortCastle() throws {
    
        try moveAndAssert("e2", to: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert("e7", to: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssert("f1", to: "c4", type:.bishop, color: .white)
        try moveAndAssert("f8", to: "c5", type:.bishop, color: .black)
        
        try moveAndAssert("g1", to: "f3", type:.knight, color: .white)
        try moveAndAssert("g8", to: "f6", type:.knight, color: .black)
        
        try moveAndAssert("e1", to: "g1", type:.king, color: .white, moveType: .Castle)
        try moveAndAssert("e8", to: "g8", type:.king, color: .black, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "Bc4", "Bc5", "Nf3", "Nf6", "O-O", "O-O"])

    }
    
    func testLongCastle() throws {
        
        try moveAndAssert("b2", to: "b3", type: .pawn, color: .white)
        try moveAndAssert("b7", to: "b6", type: .pawn, color: .black)
        
        try moveAndAssert("c1", to: "b2", type: .bishop, color: .white)
        try moveAndAssert("c8", to: "b7", type: .bishop, color: .black)
        
        try moveAndAssert("b1", to: "c3", type: .knight, color: .white)
        try moveAndAssert("b8", to: "c6", type: .knight, color: .black)
        
        try moveAndAssert("e2", to: "e3", type: .pawn, color: .white)
        try moveAndAssert("e7", to: "e6", type: .pawn, color: .black)
        
        try moveAndAssert("d1", to: "e2", type: .queen, color: .white)
        try moveAndAssert("d8", to: "e7", type: .queen, color: .black)
        
        try moveAndAssert("e1", to: "c1", type: .king, color: .white, moveType: .Castle)
        try moveAndAssert("e8", to: "c8", type: .king, color: .black, moveType: .Castle)
        
        try assertMoves(["b3", "b6", "Bb2", "Bb7", "Nc3", "Nc6", "e3", "e6", "Qe2", "Qe7", "O-O-0", "O-O-0"])

        
    }
    
    func testCastleAttemptStartInCheck() throws {
        
        try moveAndAssert("e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert("e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert("f2", to: "f3", type: .pawn, color: .white)
        try moveAndAssert("f7", to: "f5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert("f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert("d7", to: "d6", type: .pawn, color: .black)
        
        try moveAndAssert("g1", to: "h3", type: .knight, color: .white)
        try moveAndAssert("d8", to: "h4", type: .queen, color: .black)
        
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "f3", "f5", "Bc4", "d6", "Nh3", "Qh4"])
        
    }
    
    func testCastleAttemptMiddleInCheck() throws {
        
        try moveAndAssert("e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert("e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert("g1", to: "f3", type: .knight, color: .white )
        try moveAndAssert("d7", to: "d6", type: .pawn, color: .black)
        
        try moveAndAssert("h2", to: "h3", type: .pawn, color: .white)
        try moveAndAssert("c8", to: "e6", type: .bishop, color: .black)
        
        try moveAndAssert("b1", to: "a3", type: .knight, color: .white)
        try moveAndAssert("f7", to: "f6", type: .pawn, color: .black)
        
        try moveAndAssert("f1", to: "c4", type: .bishop, color: .white)
        try captureAndAssert("e6", to: "c4", type: .bishop, color: .black)
        
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "Nf3", "d6", "h3", "Be6", "Na3", "f6", "Bc4", "Bc4"])
    }
    
    
    func testCastleAttemptTargetInCheck() throws {
        
        try moveAndAssert("e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert("e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert("f2", to: "f3", type: .pawn, color: .white)
        try moveAndAssert("f8", to: "c5", type: .bishop, color: .black)
        
        try moveAndAssert("f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert("d7", to: "d6", type: .pawn, color: .black)
        
        try moveAndAssert("g1", to: "e2", type: .knight, color: .white)
        try moveAndAssert("f7", to: "f6", type: .pawn, color: .black)
        
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "f3", "Bc5", "Bc4", "d6", "Ne2", "f6"])

    }
    
    func testCastleWithoutRook() throws {
        
        try moveAndAssert("g1", to: "f3", type: .knight, color: .white)
        try moveAndAssert("b7", to: "b6", type: .pawn, color: .black)
        
        try moveAndAssert("g2", to: "g3", type: .pawn, color: .white)
        try moveAndAssert("c8", to: "b7", type: .bishop, color: .black)
        
        try moveAndAssert("f1", to: "g2", type: .bishop, color: .white)
        try moveAndAssert("e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try captureAndAssert("f3", to: "e5", type: .knight, color: .white)
        try captureAndAssert("b7", to: "g2", type: .bishop, color: .black)
        
        try captureAndAssert("e5", to: "f7", type: .knight, color: .white)
        try captureAndAssert("g2", to: "h1", type: .bishop, color: .black)
        
        try captureAndAssert("f7", to: "d8", type: .knight, color: .white)
        try captureAndAssert("e8", to: "d8", type: .king, color: .black)
        
        try moveAndAssertError("e1", to: "g1", type: .king, color: .white, moveType: .Castle)
        
        try assertMoves(["Nf3", "b6", "g3", "Bb7", "Bg2", "e5", "Ne5", "Bg2", "Nf7", "Bh1", "Nd8", "Kd8"])
        
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
        
        try moveAndAssertError(Move(8, 9,piece: Figure.create("h8", type: .king, color: .black)!, type: MoveType.Normal))
        
        let testee = try XCTUnwrap(testee)
        XCTAssertThrowsError(try testee.move(Move(8,9, piece: Figure.create("h8", type: .king, color: .black)!, type: .Normal)))
        XCTAssertFalse(figureExist(King(color: .black, row: 8, file: 9)))
        
        try assertMoves(["e4", "e5", "Bc4", "Bb4", "c3", "Nf6", "Nf3", "O-O", "b4", "Re8", "O-O", "Kh8", "Kh1"])
    }
    
    func testRowIntersection() throws {
        
        try moveAndAssert("e2", to: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert("e7", to: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert("f1", to: "c4", type: .bishop, color: .white)
        try moveAndAssert("d8", to: "h4", type: .queen, color: .black)
        
        try moveAndAssert("a2", to: "a3", type: .pawn, color: .white)
        
        try captureAndAssertError("h4", to: "c4", type: .queen, color: .black)
        try captureAndAssert("h4", to: "e4", type: .queen, color: .black)
        
        try assertMoves(["e4", "e5", "Bc4", "Qh4", "a3", "Qe4"])
        
    }
}
