//
//  Move.swift
//  SwiftChess
//
//  Created by Jan Fässler on 25.12.21.
//

import Foundation

class Move:Identifiable{
    let id:String = UUID().uuidString
    var row:Int = 0
    var file:Int = 0
    
    init(_ r:Int, _ f:Int) {
        self.row = r
        self.file = f
    }
    
    static func == (l:Move, r:Move) -> Bool {
        return l.row == r.row && l.file == r.file
    }
}
