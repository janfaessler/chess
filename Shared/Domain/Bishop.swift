//
//  Bishop.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

public class Bishop : Figure {
    
    public init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .bishop, color: color, row: row, file: file, moved: moved)
    }
    
    public override func getPossibleMoves() -> [Move] {
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
    
    public override func ident() -> String {
        return "B"
    }
}
