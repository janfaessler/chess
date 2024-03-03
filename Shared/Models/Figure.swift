//
//  FigureViewModel.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.12.21.
//

import Foundation

class Figure : Identifiable, ObservableObject {
    let id:String = UUID().uuidString
    
    static let longCastleKingPosition = 3
    static let shortCastleKingPosition = 7
    
    let type:PieceType
    let color:PieceColor
    var moved:Bool = false
        
    @Published var row:Int = 0
    @Published var file:Int = 0
    

    init(type:PieceType, color: PieceColor, row:Int, file:Int) {	
        self.type = type
        self.color = color
        self.row = row
        self.file = file
    }

    
    func move(to:Move) {
        self.row =  to.row
        self.file = to.file
        self.moved = true
    }
    
    func getPossibleMoves() -> [Move] {
        return []
    }
    
    func getMove(deltaRow:Int, deltaFile:Int) -> Move? {
        let moveToRow = row + deltaRow;
        let moveToFile = file + deltaFile;
        let moves = getPossibleMoves();
        return moves.first(where:{ $0.row == moveToRow && $0.file == moveToFile })
    }
    
    static func == (l:Figure, r:Figure) -> Bool {
        return l.row == r.row && l.file == r.file && l.type == r.type && l.color == r.color
    }
    
    static func != (l:Figure, r:Figure) -> Bool {
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
