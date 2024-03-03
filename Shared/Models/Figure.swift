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
        switch type {
            case .pawn:
                return getPawnMoves()
            case .bishop:
                return getBishopMoves()
            case .knight:
                return getKnightMoves()
            case .rook:
                return getRookMoves()
            case .queen:
                return getQueenMoves()
            case .king:
                return getKingMoves()
        }
    }
    
    func getMove(deltaRow:Int, deltaFile:Int) -> Move? {
        
        let moveToRow = row + deltaRow;
        let moveToFile = file + deltaFile;
        
        if type == .king && moved == false && moveToFile < Figure.longCastleKingPosition {
            return CreateMove(moveToRow, Figure.longCastleKingPosition, .Castle)
        }
        if type == .king && moved == false && moveToFile > Figure.shortCastleKingPosition {
            return CreateMove(moveToRow, Figure.shortCastleKingPosition, .Castle)
        }
        
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
        switch type {
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

    private func getPawnMoves() -> [Move] {
        switch color {
            case.black:
                let moveType = row == 2 ? MoveType.Promotion : MoveType.Normal
                var moves = [
                    CreateMove(row-1, file-1, moveType),
                    CreateMove(row-1, file, moveType),
                    CreateMove(row-1, file+1, moveType)]
                if row == 7 {
                    moves.append(CreateMove(row-2, file, MoveType.Double))
                }
                return moves
            case .white:
                let moveType = row == 7 ? MoveType.Promotion : MoveType.Normal
                var moves = [
                    CreateMove(row+1, file-1, moveType),
                    CreateMove(row+1, file, moveType),
                    CreateMove(row+1, file+1, moveType)]
                if row == 2 {
                    moves.append(CreateMove(row+2, file, MoveType.Double))
                }
                return moves
        }
    }
    
    private func getBishopMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (row-r == file-f || row+file == r+f) {
                    moves.append(CreateMove(r, f))
                }
            }
        }
        return moves
    }
    
    private func getKnightMoves() -> [Move] {
        let moves = [
            CreateMove(row+1, file+2),
            CreateMove(row+1, file-2),
            CreateMove(row-1, file+2),
            CreateMove(row-1, file-2),
            CreateMove(row+2, file+1),
            CreateMove(row+2, file-1),
            CreateMove(row-2, file+1),
            CreateMove(row-2, file-1)
        ]
        return moves.filter({ move in inBoard(move) })
    }
    
    private func getRookMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (r == row || f==file) {
                    moves.append(CreateMove(r, f))
                }
            }
        }
        return moves
    }
    
    private func getQueenMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (r == row || f == file || row-r == file-f || row+file == r+f) {
                    moves.append(CreateMove(r, f))
                }
            }
        }
        return moves
    }
    
    private func getKingMoves() -> [Move] {
        var moves = [
            CreateMove(row+1, file+1),
            CreateMove(row, file+1),
            CreateMove(row+1, file),
            CreateMove(row-1, file-1),
            CreateMove(row, file-1),
            CreateMove(row-1, file),
            CreateMove(row-1, file+1),
            CreateMove(row+1, file-1)
        ]
        if (!moved) {
            moves.append(contentsOf: [
                CreateMove(row, Figure.longCastleKingPosition, MoveType.Castle),
                CreateMove(row, Figure.shortCastleKingPosition, MoveType.Castle)
            ])
        }
        return moves.filter({ move in inBoard(move) })
    }
    
    private func inBoard(_ m:Move) -> Bool {
        return 1...8 ~= m.row && 1...8 ~= m.file
    }
    
    private func CreateMove(_ row:Int, _ file:Int) -> Move {
        return Move(row, file, piece: self, type: .Normal)
    }
    
    private func CreateMove(_ row:Int, _ file:Int, _ type:MoveType) -> Move {
        return Move(row, file, piece: self, type: type)
    }
}
