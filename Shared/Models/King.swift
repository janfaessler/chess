//
//  King.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

class King : Figure {
    
    
    init(color: PieceColor, row:Int, file:Int) {
        super.init(type: .king, color: color, row: row, file: file)
    }
    
    override func getPossibleMoves() -> [Move] {
        var moves = [
            CreateMove(row+1, file+1),
            CreateMove(row, file+1),
            CreateMove(row+1, file),
            CreateMove(row-1, file-1),
            CreateMove(row, file-1),
            CreateMove(row-1, file),
            CreateMove(row-1, file+1),
            CreateMove(row+1, file-1)
        ]
        if (!moved) {
            moves.append(contentsOf: [
                CreateMove(row, Figure.longCastleKingPosition, MoveType.Castle),
                CreateMove(row, Figure.shortCastleKingPosition, MoveType.Castle)
            ])
        }
        return moves.filter({ move in inBoard(move) })
    }
    
    override func getMove(deltaRow:Int, deltaFile:Int) -> Move? {
        
        let moveToRow = row + deltaRow;
        let moveToFile = file + deltaFile;
        
        if moved == false && moveToFile < Figure.longCastleKingPosition {
            return CreateMove(moveToRow, Figure.longCastleKingPosition, .Castle)
        }
        if moved == false && moveToFile > Figure.shortCastleKingPosition {
            return CreateMove(moveToRow, Figure.shortCastleKingPosition, .Castle)
        }
        
        return super.getMove(deltaRow: deltaRow, deltaFile: deltaFile)
    }
    
    override func ident() -> String {
        return "K"
    }
}
