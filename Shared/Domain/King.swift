//
//  King.swift
//  SwiftChess
//
//  Created by Jan Fässler on 03.03.2024.
//

import Foundation

public class King : Figure {
    
    public static let LongCastlePosition = 3
    public static let ShortCastlePosition = 7
    
    private let type:PieceType = .king

    public init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: type, color: color, row: row, file: file, moved: moved)
    }
    
    public init? (_ field:String, color: PieceColor) {
        super.init(field, type: type, color: color)
    }
    
    override func getPossibleMoves() -> [Move] {
        let row = getRow()
        let file = getFile()
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
        if (!hasMoved()) {
            moves.append(contentsOf: [
                CreateMove(row, King.LongCastlePosition, MoveType.Castle),
                CreateMove(row, King.ShortCastlePosition, MoveType.Castle)
            ])
        }
        return moves.filter({ move in inBoard(move) })
    }
    
    public override func isMovePossible( _ move: Move, cache:BoardCache) -> Bool {
        guard super.canDo(move: move) else { return false }
        if isShortCastling(move) {
            return canCastle(move, rookStart: Rook.ShortCastleStartingFile, cache: cache)
        } else if isLongCastling(move) {
            return canCastle(move, rookStart: Rook.LongCastleStartingFile, cache: cache)
        }
        return true
    }
    
    
    override func ident() -> String {
        return "K"
    }
    
    private func canCastle(_ to: Move, rookStart:Int, cache:BoardCache) -> Bool {
        let isNotCastlingInCheck = isCastlingInCheck(to, cache:cache) == false
        let kingHasNotMovedYet = self.hasMoved() == false
        let figureAtRookStart = cache.get(atRow: to.piece.getRow(), atFile: rookStart)
        let rookHasNotMovedYet = figureAtRookStart != nil && figureAtRookStart!.getType() == .rook && figureAtRookStart?.getColor() == getColor() && figureAtRookStart?.hasMoved() == false
        return isNotCastlingInCheck && kingHasNotMovedYet && rookHasNotMovedYet
    }
    
    private func isLongCastling(_ move: Move) -> Bool {
        return move.file == King.LongCastlePosition && isKingCastling(move)
    }
    
    private func isShortCastling(_ move: Move) -> Bool {
        return move.file == King.ShortCastlePosition && isKingCastling(move)
    }
    
    private func isKingCastling(_ move: Move) -> Bool {
        return move.piece.getType() == .king && move.type == .Castle
    }
    
    private func isCastlingInCheck(_ move:Move, cache:BoardCache) -> Bool {
         
        let isLongCastle = isLongCastling(move)
        
        guard !isFieldInCheck(move.piece.getRow(), move.piece.getFile(), cache: cache) else { return true }
        guard !isFieldInCheck(move.row, isLongCastle ? move.file + 1 : move.file - 1, cache: cache) else { return true }
        guard !isFieldInCheck(move.row, move.file, cache: cache) else { return true }
        
        return false
    }
    
    private func isFieldInCheck(_ row: Int, _ file: Int, cache:BoardCache) -> Bool {
        let figures = cache.getFigures()
        return figures.contains(where: {
            
            if $0.getColor() == getColor() { return false }
            let movepossible = $0.isMovePossible(Move(row, file, piece: $0), cache: cache)
            return movepossible
        })
    }
}
