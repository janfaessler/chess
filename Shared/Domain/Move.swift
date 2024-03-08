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
    var piece:Figure
    var type:MoveType = MoveType.Normal
    
    init(_ r:Int, _ f:Int, piece: Figure) {
        self.row = r
        self.file = f
        self.piece = piece
    }
    
    public init (_ r:Int, _ f:Int, piece: Figure, type: MoveType){
        self.init(r,f, piece: piece)
        self.type = type
    }
    
    public init?(_ fieldname:String, piece: Figure, type: MoveType) {
        guard let field = Field(fieldname) else { return nil }
        self.row = field.row
        self.file = field.file
        self.piece = piece
        self.type = type
    }

    
    public static func == (l:Move, r:Move) -> Bool {
        return l.row == r.row && l.file == r.file && l.piece == r.piece && l.type == r.type
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
    
    public func getField() -> String {
        return Field(row:row, file:file).info()
    }
    
    public func getPiece() -> Figure {
        return piece
    }
    
    func info() -> String {
        guard let scalar = UnicodeScalar(file+96) else { return "XXX" }
        let fileName = Character(scalar)
        
        if (type == .Castle) {
            if (file == 7) {
                return "O-O"
            }
            return "O-O-0"
        }
        return "\(piece.ident())\(fileName)\(row)";
    }
}
