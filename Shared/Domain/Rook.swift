//
//  Rook.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

class Rook : Figure {
    
    static let LongCastlePosition = 4
    static let ShortCastlePosition = 6
    
    init(color: PieceColor, row:Int, file:Int) {
        super.init(type: .rook, color: color, row: row, file: file)
    }
    
    override func getPossibleMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(getRow() == r && getFile() == f) && (r == getRow() || f==getFile()) {
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
