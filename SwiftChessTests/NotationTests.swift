//
//  NotationTests.swift
//  SwiftChessTests
//
//  Created by Jan Fässler on 14.03.2024.
//

import XCTest
import SwiftChess

final class NotationTests: ChessTestBase {

    func testSimplePawnCapture() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "d5", toField: "d5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "exd5", toField: "d5", type:.pawn, color: .white)
        
        try assertMoves(["e4", "d5", "exd5"])
        
    }
    
    func testEnPassantLeft() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "a6", toField: "a6", type:.pawn, color: .black)
        
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .white)
        try moveAndAssert(notation: "d5", toField: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "d6", toField: "d6", type: .pawn, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "d5", "exd6"])

    }
    
    func testEnPassanRight() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "a6", toField: "a6", type:.pawn, color: .black)
        
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .white)
        try moveAndAssert(notation: "f5", toField: "f5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "exf6", toField: "f6", type: .pawn, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "f5", "exf6"])
    }
    
    func testEnPassantToPromotion() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "a6", toField: "a6", type:.pawn, color: .black)
        
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .white)
        try moveAndAssert(notation: "d5", toField: "d5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "exd6", toField: "d6", type: .pawn, color: .white)
        try moveAndAssert(notation: "b5", toField: "b5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "dxe7", toField: "e7", type: .pawn, color: .white)
        try moveAndAssert(notation: "c5", toField: "c5", type:.pawn, color: .black, moveType: .Double)

        try moveAndAssert(notation: "exd8=Q", toField: "d8", type: .queen, color: .white)
        
        try assertMoves(["e4", "a6", "e5", "d5", "exd6", "b5", "dxe7", "c5", "exd8=Q"])

    }
    
    func testShortCastle() throws {
    
        try moveAndAssert(notation: "e4", toField: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "e5", toField: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "Bc4", toField: "c4", type:.bishop, color: .white)
        try moveAndAssert(notation: "Bc5", toField: "c5", type:.bishop, color: .black)
        
        try moveAndAssert(notation: "Nf3", toField: "f3", type:.knight, color: .white)
        try moveAndAssert(notation: "Nf6", toField: "f6", type:.knight, color: .black)
        
        try moveAndAssert(notation: "O-O", toField: "g1", type:.king, color: .white, moveType: .Castle)
        try moveAndAssert(notation: "O-O", toField: "g8", type:.king, color: .black, moveType: .Castle)
        
        try assertMoves(["e4", "e5", "Bc4", "Bc5", "Nf3", "Nf6", "O-O", "O-O"])

    }
    
    func testLongCastle() throws {
        
        try moveAndAssert(notation: "b3", toField: "b3", type: .pawn, color: .white)
        try moveAndAssert(notation: "b6", toField: "b6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "Bb2", toField: "b2", type: .bishop, color: .white)
        try moveAndAssert(notation: "Bb7", toField: "b7", type: .bishop, color: .black)
        
        try moveAndAssert(notation: "Nc3", toField: "c3", type: .knight, color: .white)
        try moveAndAssert(notation: "Nc6", toField: "c6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "e3", toField: "e3", type: .pawn, color: .white)
        try moveAndAssert(notation: "e6", toField: "e6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "Qe2", toField: "e2", type: .queen, color: .white)
        try moveAndAssert(notation: "Qe7", toField: "e7", type: .queen, color: .black)
        
        try moveAndAssert(notation: "O-O-O", toField: "c1", type: .king, color: .white, moveType: .Castle)
        try moveAndAssert(notation: "O-O-O", toField: "c8", type: .king, color: .black, moveType: .Castle)
        
        try assertMoves(["b3", "b6", "Bb2", "Bb7", "Nc3", "Nc6", "e3", "e6", "Qe2", "Qe7", "O-O-O", "O-O-O"])

    }
    
    func testCastleAttemptStartInCheck() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "f3", toField: "f3", type: .pawn, color: .white)
        try moveAndAssert(notation: "f5", toField: "f5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try moveAndAssert(notation: "d6", toField: "d6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "Nh3", toField: "h3", type: .knight, color: .white)
        try moveAndAssert(notation: "Qh4", toField: "h4", type: .queen, color: .black)
        
        try moveAndAssertError("O-O")
        
        try assertMoves(["e4", "e5", "f3", "f5", "Bc4", "d6", "Nh3", "Qh4"])
        
    }
    
    func testCastleAttemptMiddleInCheck() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "Nf3", toField: "f3", type: .knight, color: .white )
        try moveAndAssert(notation: "d6", toField: "d6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "h3", toField: "h3", type: .pawn, color: .white)
        try moveAndAssert(notation: "Be6", toField: "e6", type: .bishop, color: .black)
        
        try moveAndAssert(notation: "Na3", toField: "a3", type: .knight, color: .white)
        try moveAndAssert(notation: "f6", toField: "f6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try moveAndAssert(notation: "Bxc4", toField: "c4", type: .bishop, color: .black)
        
        try moveAndAssertError("O-O")
        
        try assertMoves(["e4", "e5", "Nf3", "d6", "h3", "Be6", "Na3", "f6", "Bc4", "Bxc4"])
    }
    
    
    func testCastleAttemptTargetInCheck() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "f3", toField: "f3", type: .pawn, color: .white)
        try moveAndAssert(notation: "Bc5", toField: "c5", type: .bishop, color: .black)
        
        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try moveAndAssert(notation: "d6", toField: "d6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "Ne2", toField: "e2", type: .knight, color: .white)
        try moveAndAssert(notation: "f6", toField: "f6", type: .pawn, color: .black)
        
        try moveAndAssertError("O-O")
        
        try assertMoves(["e4", "e5", "f3", "Bc5", "Bc4", "d6", "Ne2", "f6"])

    }
    
    func testCastleWithoutRook() throws {
        
        try moveAndAssert(notation: "Nf3", toField: "f3", type: .knight, color: .white)
        try moveAndAssert(notation: "b6", toField: "b6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "g3", toField: "g3", type: .pawn, color: .white)
        try moveAndAssert(notation: "Bb7", toField: "b7", type: .bishop, color: .black)
        
        try moveAndAssert(notation: "Bg2", toField: "g2", type: .bishop, color: .white)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "Nxe5", toField: "e5", type: .knight, color: .white)
        try moveAndAssert(notation: "Bxg2", toField: "g2", type: .bishop, color: .black)
        
        try moveAndAssert(notation: "Nxf7", toField: "f7", type: .knight, color: .white)
        try moveAndAssert(notation: "Bxh1", toField: "h1", type: .bishop, color: .black)
        
        try moveAndAssert(notation: "Nxd8", toField: "d8", type: .knight, color: .white)
        try moveAndAssert(notation: "Kxd8", toField: "d8", type: .king, color: .black)
        
        try moveAndAssertError("O-O")
        
        try assertMoves(["Nf3", "b6", "g3", "Bb7", "Bg2", "e5", "Nxe5", "Bxg2", "Nxf7", "Bxh1", "Nxd8", "Kxd8"])
        
    }
    
    func testSimpleCastleWithTryingWrongMoves() throws {
    
        try moveAndAssert(notation: "e4", toField: "e4", type:.pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "e5", toField: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try moveAndAssertError("Bc5")
        
        try moveAndAssert(notation: "Bc4", toField: "c4", type:.bishop, color: .white)
        try moveAndAssert(notation: "Bb4", toField: "b4", type:.bishop, color: .black)
        
        try moveAndAssertError("d3")
        try moveAndAssertError("d4")
        
        try moveAndAssert(notation: "c3", toField: "c3", type:.pawn, color: .white)
        try moveAndAssert(notation: "Nf6", toField: "f6", type:.knight, color: .black)
        
        try moveAndAssert(notation: "Nf3", toField: "f3", type: .knight, color: .white)
        try moveAndAssert(notation: "O-O", toField: "g8", type:.king, color: .black, moveType: .Castle)
        
        try moveAndAssert(notation: "cxb4", toField: "b4", type: .pawn, color: .white)
        try moveAndAssert(notation: "Re8", toField: "e8", type: .rook, color: .black)
        
        try moveAndAssert(notation: "O-O", toField: "g1", type:.king, color: .white, moveType: .Castle)
        try moveAndAssert(notation: "Kh8", toField: "h8", type: .king, color: .black)
        
        try moveAndAssert(notation: "Kh1", toField: "h1", type: .king, color: .white)
                
        try assertMoves(["e4", "e5", "Bc4", "Bb4", "c3", "Nf6", "Nf3", "O-O", "cxb4", "Re8", "O-O", "Kh8", "Kh1"])
    }
    
    func testRowIntersection() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try moveAndAssert(notation: "Qh4", toField: "h4", type: .queen, color: .black)
        
        try moveAndAssert(notation: "a3", toField: "a3", type: .pawn, color: .white)
        
        try moveAndAssertError("Qxc4")
        try moveAndAssert(notation: "Qxe4", toField: "e4", type: .queen, color: .black)
        
        try assertMoves(["e4", "e5", "Bc4", "Qh4", "a3", "Qxe4"])
    }
    
    func testCheckMate() throws {
        
        try moveAndAssert(notation: "e4", toField: "e4", type: .pawn, color: .white, moveType: .Double)
        try moveAndAssert(notation: "f5", toField: "f5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "Bc4", toField: "c4", type: .bishop, color: .white)
        try moveAndAssert(notation: "e6", toField: "e6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "h3", toField: "h3", type: .pawn, color: .white)
        try moveAndAssert(notation: "g5", toField: "g5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "Qh5", toField: "h5", type: .queen, color: .white)
        
        let king = Figure.create("e8", type: .king, color: .black)!;
        try assertPossibleMoves(forFigure: king, moves: [king.CreateMove("e7")!])
        
        try moveAndAssert(notation: "Ke7", toField: "e7", type: .king, color: .black)
        
        try moveAndAssert(notation: "e5", toField: "e5", type: .pawn, color: .white)
        
        try assertPossibleMoves(forFigure: Figure.create("e7", type: .king, color: .black)!, moves: [])

        try moveAndAssert(notation: "a6", toField: "a6", type: .pawn, color: .black)
        
        try moveAndAssert(notation: "d3", toField: "d3", type: .pawn, color: .white)
        try moveAndAssert(notation: "b5", toField: "b5", type: .pawn, color: .black, moveType: .Double)
        
        try moveAndAssert(notation: "Bxg5", toField: "g5", type: .bishop, color: .white)
        try moveAndAssert(notation: "Nf6", toField: "f6", type: .knight, color: .black)
        
        try moveAndAssert(notation: "Bxf6", toField: "f6", type: .bishop, color: .white)
        
        try assertMoves(["e4", "f5", "Bc4", "e6", "h3", "g5", "Qh5", "Ke7", "e5", "a6","d3","b5", "Bxg5", "Nf6", "Bxf6"])
        
    }

}
