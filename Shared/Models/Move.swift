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
}
