//
//  Rook.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

class Rook : Figure {
    
    init(color: PieceColor, row:Int, file:Int) {
        super.init(type: .rook, color: color, row: row, file: file)
    }
    
    override func getPossibleMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (r == row || f==file) {
                    moves.append(CreateMove(r, f))
                }
            }
        }
        return moves
    }
    
    override func ident() -> String {
        return "R"
    }
}
