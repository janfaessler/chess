//
//  Queen.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

public class Queen : Figure {
    
    private let type:PieceType = .queen

    public init(color: PieceColor, row:Int, file:Int) {
        super.init(type: type, color: color, row: row, file: file)
    }
    
    public init? (_ field:String, color: PieceColor) {
        super.init(field, type: type, color: color)
    }
    
    override func getPossibleMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(getRow() == r && getFile() == f) && (r == getRow() || f == getFile() || getRow()-r == getFile()-f || getRow()+getFile() == r+f) {
                    moves.append(CreateMove(r, f))
                }
            }
        }
        return moves
    }
    
    override func ident() -> String {
        return "Q"
    }
}
