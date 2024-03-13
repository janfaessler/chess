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
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
