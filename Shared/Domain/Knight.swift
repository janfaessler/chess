//
//  Knight.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation
public class Knight : Figure {
    
    public init(color: PieceColor, row:Int, file:Int) {
        super.init(type: .knight, color: color, row: row, file: file)
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
