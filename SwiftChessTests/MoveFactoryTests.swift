//
//  MoveFactoryTests.swift
//  SwiftChessTests
//
//  Created by Jan Fässler on 13.03.2024.
//

import XCTest
import SwiftChess

final class MoveFactoryTests: XCTestCase {

    private var boardCache:BoardCache?
    
    override func setUpWithError() throws {
        let position = Fen.loadStartingPosition();
        boardCache = BoardCache.create(position.figures)
    }

    func testPawnMoves() throws {
        try assertMove("e4", field: "e4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("e5", field: "e5", type: .pawn, color: .black, moveType: .Double)
        try assertMove("d4", field: "d4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("exd4", field: "d4", type: .pawn, color: .black)
        try assertMove("e5", field: "e5", type: .pawn, color: .white)
        try assertMove("f5", field: "f5", type: .pawn, color: .black, moveType: .Double)
        try assertMove("exf6", field: "f6", type: .pawn, color: .white)
        try assertMove("d3", field: "d3", type: .pawn, color: .black)
        try assertMove("fxg7", field: "g7", type: .pawn, color: .white)
        try assertMove("dxc2", field: "c2", type: .pawn, color: .black)
        try assertMove("gxh8=Q", field: "h8", type: .pawn, color: .white, moveType: .Promotion)
        try assertMove("cxb1=Q", field: "b1", type: .pawn, color: .black, moveType: .Promotion)
    }
    
    func testPieceMoves() throws {
        try assertMove("e4", field: "e4", type: .pawn, color: .white, moveType: .Double)
        try assertMove("e5", field: "e5", type: .pawn, color: .black, moveType: .Double)
        try assertMove("Nc3", field: "c3", type: .knight, color: .white)
        try assertMove("Nc6", field: "c6", type: .knight, color: .black)
        try assertMove("Bc4", field: "c4", type: .bishop, color: .white)
        try assertMove("Bc5", field: "c5", type: .bishop, color: .black)
        try assertMove("Qg4", field: "g4", type: .queen, color: .white)
        try assertMove("Qf6", field: "f6", type: .queen, color: .black)
        try assertMove("Nd5", field: "d5", type: .knight, color: .white)
        try assertMove("Qxf2+", field: "f2", type: .queen, color: .black)
        try assertMove("Kd1", field: "d1", type: .king, color: .white)
        try assertMove("Bb6", field: "b6", type: .bishop, color: .black)
        try assertMove("Nh3", field: "h3", type: .knight, color: .white)
        try assertMove("d6", field: "d6", type: .pawn, color: .black)
        try assertMove("Nxf2", field: "f2", type: .knight, color: .white)
        try assertMove("Bxg4+", field: "g4", type: .bishop, color: .black)
        try assertMove("Nxg4", field: "g4", type: .knight, color: .white)
    }
    
    func testShortCastle() throws {
    
        try assertMove("e4", field: "e4", type:.pawn, color: .white, moveType: .Double)
        try assertMove("e5", field: "e5", type:.pawn, color: .black, moveType: .Double)
        
        try assertMove("Bc4", field: "c4", type:.bishop, color: .white)
        try assertMove("Bc5", field: "c5", type:.bishop, color: .black)
        
        try assertMove("Nf3", field: "f3", type:.knight, color: .white)
        try assertMove("Nf6", field: "f6", type:.knight, color: .black)
        
        try assertMove("O-O", field: "g1", type:.king, color: .white, moveType: .Castle)
        try assertMove("O-O", field: "g8", type:.king, color: .black, moveType: .Castle)
        
    }
    
    func testLongCastle() throws {
        
        try assertMove("b3", field: "b3", type: .pawn, color: .white)
        try assertMove("b6", field: "b6", type: .pawn, color: .black)
        
        try assertMove("Bb2", field: "b2", type: .bishop, color: .white)
        try assertMove("Bb7", field: "b7", type: .bishop, color: .black)
        
        try assertMove("Nc3", field: "c3", type: .knight, color: .white)
        try assertMove("Nc6", field: "c6", type: .knight, color: .black)
        
        try assertMove("e3", field: "e3", type: .pawn, color: .white)
        try assertMove("e6", field: "e6", type: .pawn, color: .black)
        
        try assertMove("Qe2", field: "e2", type: .queen, color: .white)
        try assertMove("Qe7", field: "e7", type: .queen, color: .black)
        
        try assertMove("O-O-O", field: "c1", type: .king, color: .white, moveType: .Castle)
        try assertMove("O-O-O", field: "c8", type: .king, color: .black, moveType: .Castle)
        
    }
    
    private func assertMove(
        _ moveName:String,
        field:String,
        type:PieceType,
        color:PieceColor,
        moveType:MoveType = .Normal,
        message: (Move?) -> String = { $0 == nil ? "Move not found ": "Move[\($0!.getFieldInfo()), \($0!.getPiece().getType()),\($0!.getPiece().getColor()), \($0!.getType())]  is the wrong move" },
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let cache = try XCTUnwrap(boardCache)
        let move:Move? = MoveFactory.create(moveName, cache:cache);
        
        guard move == nil || move?.getPiece().getType() != type || move?.getPiece().getColor() != color || move?.getFieldInfo() != field || move?.getType() != moveType else {
            try updateBoardCache(move!)
            return
        }
        
        XCTFail(message(move), file: file, line: line)
    }
    
    private func updateBoardCache(_ move:Move) throws {
        var figures:[ChessFigure] = try XCTUnwrap(boardCache).getFigures()
        let fig = figures.first(where: { $0.equals(move.getPiece())})!
        fig.move(row: move.getRow(), file: move.getFile())
        figures.removeAll(where: {$0.equals(move.getPiece())})
        figures.append(fig)
        boardCache = BoardCache.create(figures, lastMove: move)
    }
}
