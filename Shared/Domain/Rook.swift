//
//  Rook.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

public class Rook : Figure {
    
    public static let LongCastleStartingFile = 1
    public static let LongCastleEndFile = 4
    public static let ShortCastleStartingFile = 8
    public static let ShortCastleEndFile = 6
    
    public init(color: PieceColor, row:Int, file:Int) {
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
