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
    
    func enrichMove(move: Move) -> Move? {
        
        if move.piece == .king && moved == false && move.file < Figure.longCastleKingPosition {
            return Move(move.row, Figure.longCastleKingPosition, piece: .king, type: .Castle)
        }
        if move.piece == .king && moved == false && move.file > Figure.shortCastleKingPosition {
            return Move(move.row, Figure.shortCastleKingPosition, piece: .king, type: .Castle)
        }
        
        let moves = getPossibleMoves();
        return moves.first(where:{ $0 == move })
    }
    
    static func == (l:Figure, r:Figure) -> Bool {
        return l.row == r.row && l.file == r.file && l.type == r.type && l.color == r.color
    }
    
    static func != (l:Figure, r:Figure) -> Bool {
        return !(l == r)
    }

    private func getPawnMoves() -> [Move] {
        switch color {
            case.black:
                let moveType = row == 2 ? MoveType.Promotion : MoveType.Normal
                var moves = [
                    Move(row-1, file-1,piece: PieceType.pawn, type: moveType),
                    Move(row-1, file, piece: PieceType.pawn, type:moveType),
                    Move(row-1, file+1, piece: PieceType.pawn, type:moveType)]
                if row == 7 {
                    moves.append(Move(row-2, file, piece: PieceType.pawn, type: MoveType.Double))
                }
                return moves
            case .white:
                let moveType = row == 7 ? MoveType.Promotion : MoveType.Normal
                var moves = [
                    Move(row+1, file-1, piece: PieceType.pawn, type: moveType),
                    Move(row+1, file, piece: PieceType.pawn, type: moveType),
                    Move(row+1, file+1, piece: PieceType.pawn, type: moveType)]
                if row == 2 {
                    moves.append(Move(row+2, file, piece: PieceType.pawn, type: MoveType.Double))
                }
                return moves
        }
    }
    
    private func getBishopMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (row-r == file-f || row+file == r+f) {
                    moves.append(Move(r, f, piece: PieceType.bishop))
                }
            }
        }
        return moves
    }
    
    private func getKnightMoves() -> [Move] {
        let moves = [
            Move(row+1, file+2, piece: PieceType.knight),
            Move(row+1, file-2, piece: PieceType.knight),
            Move(row-1, file+2, piece: PieceType.knight),
            Move(row-1, file-2, piece: PieceType.knight),
            Move(row+2, file+1, piece: PieceType.knight),
            Move(row+2, file-1, piece: PieceType.knight),
            Move(row-2, file+1, piece: PieceType.knight),
            Move(row-2, file-1, piece: PieceType.knight)
        ]
        return moves.filter({ move in inBoard(move) })
    }
    
    private func getRookMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (r == row || f==file) {
                    moves.append(Move(r, f, piece: PieceType.rook))
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
                    moves.append(Move(r, f, piece: PieceType.queen))
                }
            }
        }
        return moves
    }
    
    private func getKingMoves() -> [Move] {
        var moves = [
            Move(row+1, file+1, piece: PieceType.king),
            Move(row, file+1, piece: PieceType.king),
            Move(row+1, file, piece: PieceType.king),
            Move(row-1, file-1, piece: PieceType.king),
            Move(row, file-1, piece: PieceType.king),
            Move(row-1, file, piece: PieceType.king),
            Move(row-1, file+1, piece: PieceType.king),
            Move(row+1, file-1, piece: PieceType.king)
        ]
        if (!moved) {
            moves.append(contentsOf: [
                Move(row, Figure.longCastleKingPosition, piece: PieceType.king, type: MoveType.Castle),
                Move(row, Figure.shortCastleKingPosition, piece: PieceType.king, type: MoveType.Castle)
            ])
        }
        return moves.filter({ move in inBoard(move) })
    }
    
    private func inBoard(_ m:Move) -> Bool {
        return 1...8 ~= m.row && 1...8 ~= m.file
    }
}
