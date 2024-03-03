//
//  Move.swift
//  SwiftChess
//
//  Created by Jan Fässler on 25.12.21.
//

import Foundation

public enum MoveType {
    case Normal,Castle,Double,Promotion
}

public struct Move:Identifiable{
    public let id:String = UUID().uuidString
    
    var row:Int = 0
    var file:Int = 0
    var piece:PieceType
    var type:MoveType = MoveType.Normal
    
    init(_ r:Int, _ f:Int, piece: PieceType) {
        self.row = r
        self.file = f
        self.piece = piece
    }
    
    init (_ r:Int, _ f:Int, piece: PieceType, type: MoveType){
        self.init(r,f, piece: piece)
        self.type = type
    }
    
    
    static func == (l:Move, r:Move) -> Bool {
        return l.row == r.row && l.file == r.file
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
        return "\(ident())\(fileName)\(row)";
    }
    
    func ident() -> String {
        switch piece {
            case .pawn:
                return ""
            case .bishop:
                return "B"
            case .knight:
                return "K"
            case .rook:
                return "R"
            case .queen:
                return "Q"
            case .king:
                return "K"
        }
    }

}
