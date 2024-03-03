//
//  Move.swift
//  SwiftChess
//
//  Created by Jan Fässler on 25.12.21.
//

import Foundation

public enum MoveType {
    case Normal,Castle,Double,Promotion,Revert
}

public struct Move:Identifiable{
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
    
    init (_ r:Int, _ f:Int, piece: Figure, type: MoveType){
        self.init(r,f, piece: piece)
        self.type = type
    }

    
    static func == (l:Move, r:Move) -> Bool {
        return l.row == r.row && l.file == r.file && l.piece == r.piece
    }
    
    static func != (l:Move, r:Move) -> Bool {
        return !(l == r)
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
