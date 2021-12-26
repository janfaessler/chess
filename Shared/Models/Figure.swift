//
//  FigureViewModel.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.12.21.
//

import SwiftUI
import Foundation

class Figure : Identifiable, ObservableObject {
    let id:String = UUID().uuidString
    
    let type:PieceType
    let color:PieceColor
        
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
    
    static func == (l:Figure, r:Figure) -> Bool {
        return l.row == r.row && l.file == r.file && l.type == r.type && l.color == r.color
    }
    
    static func != (l:Figure, r:Figure) -> Bool {
        return !(l == r)
    }

    private func getPawnMoves() -> [Move] {
        switch color {
            case.black:
                var moves = [Move(row-1, file-1),Move(row-1, file),Move(row-1, file+1)]
                if row == 7 {
                    moves.append(Move(row-2, file))
                }
                return moves
            case .white:
                var moves = [Move(row+1, file-1),Move(row+1, file),Move(row+1, file+1)]
                if row == 2 {
                    moves.append(Move(row+2, file))
                }
                return moves
        }
    }
    
    private func getBishopMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (row-r == file-f || row+file == r+f) {
                    moves.append(Move(r, f))
                }
            }
        }
        return moves
    }
    
    private func getKnightMoves() -> [Move] {
        let moves = [
            Move(row+1, file+2),
            Move(row+1, file-2),
            Move(row-1, file+2),
            Move(row-1, file-2),
            Move(row+2, file+1),
            Move(row+2, file-1),
            Move(row-2, file+1),
            Move(row-2, file-1)
        ]
        return moves.filter({ move in inBoard(move) })
    }
    
    private func getRookMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (r == row || f==file) {
                    moves.append(Move(r, f))
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
                    moves.append(Move(r, f))
                }
            }
        }
        return moves
    }
    
    private func getKingMoves() -> [Move] {
        let moves = [
            Move(row+1, file+1),
            Move(row, file+1),
            Move(row+1, file),
            Move(row-1, file-1),
            Move(row, file-1),
            Move(row-1, file),
            Move(row-1, file+1),
            Move(row+1, file-1)
        ]
        return moves.filter({ move in inBoard(move) })
    }
    
    private func inBoard(_ m:Move) -> Bool {
        return 1...8 ~= m.row && 1...8 ~= m.file
    }
}
