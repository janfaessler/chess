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
    
    public init(type:PieceType, color: PieceColor, row:Int, file:Int) {
        self.type = type
        self.color = color
        self.row = row
        self.file = file
    }
    
    public init?(_ fieldname:String, type:PieceType, color: PieceColor) {
        guard let field = Field(fieldname) else { return nil }
        self.row = field.row
        self.file = field.file
        self.type = type
        self.color = color
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
            return Pawn(color: color, row: row, file: file).getPossibleMoves()
        case .bishop:
            return Bishop(color: color, row: row, file: file).getPossibleMoves()
        case .knight:
            return Knight(color: color, row: row, file: file).getPossibleMoves()
        case .rook:
            return Rook(color: color, row: row, file: file).getPossibleMoves()
        case .queen:
            return Queen(color: color, row: row, file: file).getPossibleMoves()
        case .king:
            return King(color: color, row: row, file: file).getPossibleMoves()
        }
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
        return Field(row:row, file:file).info()
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
}
