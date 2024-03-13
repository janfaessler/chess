//
//  Move.swift
//  SwiftChess
//
//  Created by Jan Fässler on 25.12.21.
//

import Foundation

public struct Move:Identifiable, Equatable{
    
    public let id:String = UUID().uuidString
    
    var row:Int = 0
    var file:Int = 0
    var piece:ChessFigure
    var type:MoveType = MoveType.Normal
    var startingField:Field
    
    init(_ r:Int, _ f:Int, piece: ChessFigure) {
        self.row = r
        self.file = f
        self.piece = piece
        self.startingField = piece.getField()
    }
    
    public init (_ r:Int, _ f:Int, piece: ChessFigure, type: MoveType){
        self.init(r,f, piece: piece)
        self.type = type
    }
    
    public init?(_ fieldname:String, piece: ChessFigure, type: MoveType) {
        guard let field = Field(fieldname) else { return nil }
        self.init(field.row, field.file, piece: piece, type: type)
    }

    
    public static func == (l:Move, r:Move) -> Bool {
        return l.row == r.row && l.file == r.file && l.piece.equals(r.piece) && l.type == r.type
    }
    
    static func != (l:Move, r:Move) -> Bool {
        return !(l == r)
    }
    
    public func getRow() -> Int {
        return row
    }
    
    public func getFile() -> Int {
        return file
    }
    
    public func getType() -> MoveType {
        return type
    }
    
    public func getFieldInfo() -> String {
        return getField().info()
    }
    
    public func getField() -> Field {
        return Field(row:row, file:file)
    }
    
    public func getStartingField() -> Field {
        return startingField
    }
    
    public func getPiece() -> ChessFigure {
        return piece
    }
    
    public func info() -> String {
        guard let scalar = UnicodeScalar(file+96) else { return "XXX" }
        let fileName = Character(scalar)
        
        if (type == .Castle) {
            if (file == 7) {
                return "O-O"
            }
            return "O-O-0"
        }
        return "\(fileName)\(row)";
    }
}
