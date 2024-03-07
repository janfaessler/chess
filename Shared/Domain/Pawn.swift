//
//  Pawn.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

public class Pawn : Figure {
    
    private let type:PieceType = .pawn

    public init(color: PieceColor, row:Int, file:Int) {
        super.init(type: type, color: color, row: row, file: file)
    }
    
    public init? (_ field:String, color: PieceColor) {
        super.init(field, type: type, color: color)
    }
    
    override func getPossibleMoves() -> [Move] {
        let row = getRow()
        let file = getFile()
        switch getColor() {
            case.black:
                let moveType = row == 2 ? MoveType.Promotion : MoveType.Normal
                var moves = [
                    CreateMove(row-1, file-1, moveType),
                    CreateMove(row-1, file, moveType),
                    CreateMove(row-1, file+1, moveType)]
                if row == 7 {
                    moves.append(CreateMove(row-2, file, MoveType.Double))
                }
                return moves
            case .white:
                let moveType = row == 7 ? MoveType.Promotion : MoveType.Normal
                var moves = [
                    CreateMove(row+1, file-1, moveType),
                    CreateMove(row+1, file, moveType),
                    CreateMove(row+1, file+1, moveType)]
                if row == 2 {
                    moves.append(CreateMove(row+2, file, MoveType.Double))
                }
                return moves
        }
    }

    override func ident() -> String {
        return ""
    }
}
