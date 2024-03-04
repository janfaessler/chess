//
//  Bishop.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

class Bishop : Figure {
    
    init(color: PieceColor, row:Int, file:Int) {
        super.init(type: .bishop, color: color, row: row, file: file)
    }
    
    override func getPossibleMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(getRow() == r && getFile() == f) && (getRow()-r == getFile()-f || getRow()+getFile() == r+f) {
                    moves.append(CreateMove(r, f))
                }
            }
        }
        return moves
    }
    
    override func ident() -> String {
        return "B"
    }
}
