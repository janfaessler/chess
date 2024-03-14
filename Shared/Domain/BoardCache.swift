//
//  File.swift
//  SwiftChess
//
//  Created by Jan Fässler on 09.03.2024.
//

import Foundation

public class BoardCache {
    
    private var cache:[Int:[Int:ChessFigure]]
    private var lastMove:Move?
    
    private init(input:[Int:[Int:ChessFigure]], lastMove:Move?) {
        cache = input
        self.lastMove = lastMove
    }
    
    public static func create(_ figures: [ChessFigure], lastMove:Move? = nil) -> BoardCache {
        var dict:[Int:[Int:ChessFigure]] = [:]
        for f in figures {
            if dict[f.getRow()] == nil {
                dict[f.getRow()] = [:]
            }
            dict[f.getRow()]![f.getFile()] = f
        }
        return BoardCache(input: dict, lastMove: lastMove)
    }
    
    public func get(atRow:Int, atFile:Int) -> ChessFigure? {
        return cache[atRow]?[atFile]
    }
    
    public func clearField(atRow:Int, atFile:Int) {
        cache[atRow]?[atFile] = nil
    }
    
    public func set(_ figure:ChessFigure) {
        if cache[figure.getRow()] == nil {
            cache[figure.getRow()] = [:]
        }
        cache[figure.getRow()]![figure.getFile()] = figure
    }
    
    public func isEmpty(atRow:Int, atFile:Int) -> Bool {
        return get(atRow: atRow, atFile: atFile) == nil
    }
    
    public func isNotEmpty(atRow:Int, atFile:Int) -> Bool {
        return isEmpty(atRow: atRow, atFile: atFile) == false
    }
    
    public func getLastMove() -> Move? {
        return lastMove
    }
    
    public func getFigures() -> [ChessFigure] {
        return cache.flatMap({ fileKey, row in return row.values})
    }
    
    public func getNextPiece(_ move: Move) -> ChessFigure? {
        let deltaFile = abs(move.piece.getFile() - move.file)
        let deltaRow = abs(move.piece.getRow() - move.row)
        
        if deltaRow == 0 {
            return getNextPieceOnRow(from: move.piece.getField(), to: move.getField())
        } else if deltaFile == 0 {
            return getNextPieceOnFile(from: move.piece.getField(), to: move.getField())
        } else if deltaRow == deltaFile {
            return getNextPieceOnDiagonal(from: move.piece.getField(), to: move.getField())
        }
        return get(atRow: move.row, atFile: move.file)
    }
    
    public func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        let figures = getFigures()
        return figures.contains(where: {
            
            if $0.getColor() != lastMove?.getPiece().getColor() { return false }
            let movepossible = $0.isMovePossible(Move(row, file, piece: $0), cache: self)
            return movepossible
        })
    }
    
    private func getNextPieceOnRow(from:Field, to:Field) -> ChessFigure? {
        let direction = from.file < to.file ? 1 : -1
        for f in stride(from: from.file + direction, to: to.file, by: direction)  {
            let foundPiece = get(atRow: from.row, atFile: f)
            if foundPiece != nil {
                return foundPiece
            }
        }
        return get(atRow: to.row, atFile: to.file)
    }
    
    private func getNextPieceOnFile(from:Field, to:Field) -> ChessFigure? {
        let direction = from.row < to.row ? 1 : -1
        for r in stride(from: from.row + direction, to: to.row, by: direction) {
            let foundPiece = get(atRow: r, atFile: from.file)
            if foundPiece != nil {
                return foundPiece
            }
        }
        return get(atRow: to.row, atFile: to.file)

    }
    
    private func getNextPieceOnDiagonal(from:Field, to:Field) -> ChessFigure? {
        let rowDir = min(max(to.row - from.row, -1), 1)
        let fileDir = min(max(to.file - from.file, -1), 1)
        let delta = abs(from.file - to.file)
        if delta > 1 {
            for i in 1...delta {
                let row = from.row+(i*rowDir)
                let file = from.file+(i*fileDir)
                let foundPiece = get(atRow: row, atFile: file)
                if foundPiece != nil {
                    return foundPiece
                }
            }
        }

        return get(atRow: to.row, atFile: to.file)
    }
}
