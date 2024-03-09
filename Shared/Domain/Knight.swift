//
//  Knight.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation
public class Knight : Figure {
    
    private let type:PieceType = .knight

    public init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: type, color: color, row: row, file: file, moved: moved)
    }
    
    public init? (_ field:String, color: PieceColor) {
        super.init(field, type: type, color: color)
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
    
    public override func isMovePossible( _ move: Move, cache:BoardCache) -> Bool {
        guard canDo(move: move) else {
            return false
        }
        
        guard let pieceAtTarget = cache.get(atRow: move.row, atFile: move.file) else {
            return true
        }
        
        return super.isCaptureablePiece(move, pieceToCapture: pieceAtTarget);
    }
    
    override func ident() -> String {
        return "N"
    }
}
