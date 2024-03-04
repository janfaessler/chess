//
//  King.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

class King : Figure {
    
    static let LongCastlePosition = 3
    static let ShortCastlePosition = 7
    
    init(color: PieceColor, row:Int, file:Int) {
        super.init(type: .king, color: color, row: row, file: file)
    }
    
    override func getPossibleMoves() -> [Move] {
        let row = getRow()
        let file = getFile()
        var moves = [
            CreateMove(row+1, file+1),
            CreateMove(row, file+1),
            CreateMove(row+1, file),
            CreateMove(row-1, file-1),
            CreateMove(row, file-1),
            CreateMove(row-1, file),
            CreateMove(row-1, file+1),
            CreateMove(row+1, file-1)
        ]
        if (!hasMoved()) {
            moves.append(contentsOf: [
                CreateMove(row, King.LongCastlePosition, MoveType.Castle),
                CreateMove(row, King.ShortCastlePosition, MoveType.Castle)
            ])
        }
        return moves.filter({ move in inBoard(move) })
    }
    
    
    override func ident() -> String {
        return "K"
    }
}
