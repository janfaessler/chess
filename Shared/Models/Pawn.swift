//
//  Pawn.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

class Pawn : Figure {
    
    
    init(color: PieceColor, row:Int, file:Int) {
        super.init(type: .pawn, color: color, row: row, file: file)
    }
    
    override func getPossibleMoves() -> [Move] {
        switch color {
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
