//
//  Figure.swift
//  SwiftChess
//
//  Created by Jan Fässler on 04.03.2024.
//

import Foundation

public class Figure:Identifiable, Equatable {
    
    private let type:PieceType
    private let color:PieceColor
    private var moved:Bool = false
    private var row:Int = 0
    private var file:Int = 0
    
    public init(type:PieceType, color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        self.type = type
        self.color = color
        self.row = row
        self.file = file
        self.moved = moved
    }
    
    public init?(_ fieldname:String, type:PieceType, color: PieceColor, moved:Bool = false) {
        guard let field = Field(fieldname) else { return nil }
        self.row = field.row
        self.file = field.file
        self.type = type
        self.color = color
        self.moved = moved
    }
    
    func move(row:Int, file:Int) {
        self.row =  row
        self.file = file
        self.moved = true
    }
    
    func canDo(move:Move) -> Bool {
        let moves = getPossibleMoves()
        return moves.contains(where:{$0.row == move.row && $0.file == move.file})
    }


    func getPossibleMoves() -> [Move] {
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

        guard let intersectingPiece = getNextPieceOnTheWay(move, cache: cache) else {
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
    
    public func getField() -> String {
        return getFieldObject().info()
    }
    
    public func getFieldObject() -> Field {
        return Field(row:row, file:file)
    }
    
    public func info() -> String {
        return "(\(color) \(type) \(getField()))"
    }
    
    func hasMoved() -> Bool {
        return moved
    }
    
    public static func == (l:Figure, r:Figure) -> Bool {
        return l.row == r.row && l.file == r.file && l.type == r.type && l.color == r.color
    }
    
    public static func != (l:Figure, r:Figure) -> Bool {
        return !(l == r)
    }

    func ident() -> String {
        return ""
    }
    
    func inBoard(_ m:Move) -> Bool {
        return 1...8 ~= m.row && 1...8 ~= m.file
    }
    
    func CreateMove(_ row:Int, _ file:Int) -> Move {
        return Move(row, file, piece: self, type: .Normal)
    }
    
    func CreateMove(_ row:Int, _ file:Int, _ type:MoveType) -> Move {
        return Move(row, file, piece: self, type: type)
    }
    
    private func getNextPieceOnTheWay(_ move: Move, cache:BoardCache) -> Figure? {
        let deltaFile = abs(move.piece.getFile() - move.file)
        let deltaRow = abs(move.piece.getRow() - move.row)
        
        if deltaRow == 0 {
            return cache.getIntersectingPieceOnRow(from: move.piece.getFieldObject(), to: move.getFieldObject())
        } else if deltaFile == 0 {
            return cache.getIntersectingPieceOnFile(from: move.piece.getFieldObject(), to: move.getFieldObject())
        } else if deltaRow == deltaFile {
            return cache.getIntersectingPieceOnDiagonal(from: move.piece.getFieldObject(), to: move.getFieldObject())
        }
        
        return nil
    }
    
    func isCaptureablePiece(_ move: Move, pieceToCapture: Figure?) -> Bool {
        return move.piece.getColor() != pieceToCapture!.getColor() && pieceToCapture!.getRow() == move.row && pieceToCapture!.getFile() == move.file
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
