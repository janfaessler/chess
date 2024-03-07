//
//  King.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

public class King : Figure {
    
    public static let LongCastlePosition = 3
    public static let ShortCastlePosition = 7
    
    private let type:PieceType = .king

    public init(color: PieceColor, row:Int, file:Int) {
        super.init(type: type, color: color, row: row, file: file)
    }
    
    public init? (_ field:String, color: PieceColor) {
        super.init(field, type: type, color: color)
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
