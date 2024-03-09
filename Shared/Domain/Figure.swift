//
//  Figure.swift
//  SwiftChess
//
//  Created by Jan Fässler on 04.03.2024.
//

import Foundation

public class Figure:Identifiable, Equatable, ChessFigure {

    private let type:PieceType
    private let color:PieceColor
    private var moved:Bool
    private var row:Int
    private var file:Int
    
    init(type:PieceType, color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        self.type = type
        self.color = color
        self.row = row
        self.file = file
        self.moved = moved
    }
    
    public static func create(_ fieldname:String, type:PieceType, color: PieceColor, moved:Bool = false) -> ChessFigure? {
        guard let field = Field(fieldname) else { return nil }
        return Figure.create(type: type, color: color, row: field.row, file: field.file, moved: moved)
    }
    
    public static func create(type:PieceType, color: PieceColor, row:Int, file:Int, moved:Bool = false) -> ChessFigure {
        switch type {
            case .pawn: return Pawn(color: color, row: row, file: file, moved: moved)
            case .knight: return Knight(color: color, row: row, file: file, moved: moved)
            case .bishop: return Bishop(color: color, row: row, file: file, moved: moved)
            case .rook: return Rook(color: color, row: row, file: file, moved: moved)
            case .queen: return Queen(color: color, row: row, file: file, moved: moved)
            case .king: return King(color: color, row: row, file: file, moved: moved)
        }
    }
    
    public func equals(_ other: any ChessFigure) -> Bool {
        return row == other.getRow()
        && file == other.getFile()
        && type == other.getType()
        && color == other.getColor()
    }
    
    public func move(row:Int, file:Int) {
        self.row =  row
        self.file = file
        self.moved = true
    }
    
    public func canDo(move:Move) -> Bool {
        let moves = getPossibleMoves()
        return moves.contains(where:{$0.row == move.row && $0.file == move.file})
    }

    public func getPossibleMoves() -> [Move] {
        switch type {
            case .pawn:
                return toPawn().getPossibleMoves()
            case .bishop:
                return toBishop().getPossibleMoves()
            case .knight:
                return toKnight().getPossibleMoves()
            case .rook:
                return toRook().getPossibleMoves()
            case .queen:
                return toQueen().getPossibleMoves()
            case .king:
                return toKing().getPossibleMoves()
        }
    }
    
    public func isMovePossible(_ move: Move, cache:BoardCache) -> Bool {
        
        guard type != .pawn else {
            return toPawn().isMovePossible(move, cache: cache)
        }
        
        guard type != .king else {
            return toKing().isMovePossible(move, cache: cache)
        }
        
        guard type != .knight else {
            return toKnight().isMovePossible(move, cache: cache)
        }
        
        guard canDo(move: move) else {
            return false
        }

        guard let intersectingPiece = getNextPiece(move, cache: cache) else {
            return true
        }
        
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
    }
    
    public func getRow() -> Int {
        return row
    }
    
    public func getFile() -> Int {
        return file
    }
    
    public func getColor() -> PieceColor {
        return color
    }
    
    public func getType() -> PieceType {
        return type
    }
    
    public func getFieldInfo() -> String {
        return getField().info()
    }
    
    public func getField() -> Field {
        return Field(row:row, file:file)
    }
    
    public func info() -> String {
        return "(\(color) \(type) \(getFieldInfo()))"
    }
    
    public func hasMoved() -> Bool {
        return moved
    }
    
    public static func == (l:Figure, r:Figure) -> Bool {
        return l.row == r.row && l.file == r.file && l.type == r.type && l.color == r.color
    }
    
    public static func != (l:Figure, r:Figure) -> Bool {
        return !(l == r)
    }

    public func ident() -> String {
        return ""
    }
    
    func inBoard(_ m:Move) -> Bool {
        return 1...8 ~= m.row && 1...8 ~= m.file
    }
    
    func CreateMove(_ row:Int, _ file:Int) -> Move {
        return Move(row, file, piece: self, type: .Normal)
    }
    
    public func CreateMove(_ row:Int, _ file:Int, _ type:MoveType) -> Move {
        return Move(row, file, piece: self, type: type)
    }
    
    func isCaptureablePiece(_ move: Move, pieceToCapture: ChessFigure?) -> Bool {
        return move.piece.getColor() != pieceToCapture!.getColor() && pieceToCapture!.getRow() == move.row && pieceToCapture!.getFile() == move.file
    }
    
    private func getNextPiece(_ move: Move, cache:BoardCache) -> ChessFigure? {
        let deltaFile = abs(move.piece.getFile() - move.file)
        let deltaRow = abs(move.piece.getRow() - move.row)
        
        if deltaRow == 0 {
            return cache.getNextPieceOnRow(from: move.piece.getField(), to: move.getFieldObject())
        } else if deltaFile == 0 {
            return cache.getNextPieceOnFile(from: move.piece.getField(), to: move.getFieldObject())
        } else if deltaRow == deltaFile {
            return cache.getNextPieceOnDiagonal(from: move.piece.getField(), to: move.getFieldObject())
        }
        
        return nil
    }
    
    private func toPawn() -> Pawn {
        return Pawn(color: color, row: row, file: file, moved: moved)
    }
    
    private func toBishop() -> Bishop {
        return Bishop(color: color, row: row, file: file, moved: moved)
    }
    
    private func toKnight() -> Knight {
        return Knight(color: color, row: row, file: file, moved: moved)
    }
    
    private func toRook() -> Rook {
        return Rook(color: color, row: row, file: file, moved: moved)
    }
    
    private func toKing() -> King {
        return King(color: color, row: row, file: file, moved: moved)
    }
    
    private func toQueen() -> Queen {
        return Queen(color: color, row: row, file: file, moved: moved)
    }
    
}
