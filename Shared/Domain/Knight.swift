//
//  Knight.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation
public class Knight : Figure {
    
    private let type:PieceType = .knight

    public init(color: PieceColor, row:Int, file:Int) {
        super.init(type: type, color: color, row: row, file: file)
    }
    
    public init? (_ field:String, color: PieceColor) {
        super.init(field, type: type, color: color)
    }
    
    override func getPossibleMoves() -> [Move] {
        let row = getRow()
        let file = getFile()
        let moves = [
            CreateMove(row+1, file+2),
            CreateMove(row+1, file-2),
            CreateMove(row-1, file+2),
            CreateMove(row-1, file-2),
            CreateMove(row+2, file+1),
            CreateMove(row+2, file-1),
            CreateMove(row-2, file+1),
            CreateMove(row-2, file-1)
        ]
        return moves.filter({ move in inBoard(move) })
    }
    
    override func ident() -> String {
        return "N"
    }
}
