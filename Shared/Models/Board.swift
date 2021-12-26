//
//  BoardViewModel.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.12.21.
//

import SwiftUI

class Board : ObservableObject {
    
    @Published var figures:[Figure] = []
    @Published var focus:Figure?
    
    private var figuresDict:[Int:[Int:Figure]] = [:]
    private var colorToMove:PieceColor = .white
    
    func move(figure: Figure, target:Move) {
        if IsMoveLegal(piece: figure, target: target) {
            captureFigureAt(row: target.row, file: target.file)
            figure.move(to: target)
            // Todo: Promotion
            recreateFiguresCache()
            colorToMove = colorToMove == .black ? .white : .black
        }
    }
    
    func getLegalMoves() -> [Move] {
        if focus != nil {
            let possibleMoves = focus!.getPossibleMoves()
            return possibleMoves.filter({ move in IsMoveLegal(piece: focus!, target: move)})
        }
        return []
    }
    
    func setFocus(_ fig: Figure) {
        focus = fig
    }
    
    func clearFocus() {
        if focus != nil {
            focus = nil
        }
    }
    
    func addFigures() {
        let pos = Fen.loadStartingPosition()
        figures.append(contentsOf: pos.figures)
        recreateFiguresCache()
    }
    
    private func IsMoveLegal(piece: Figure, target:Move) -> Bool {
        if piece.color != colorToMove {
            return false
        }
        
        if !isMoveInBoard(target) {
            return false
        }
        
        if !isMovePossible(target, forPiece: piece) {
            return false
        }
        
        return true
    }
    
    private func captureFigureAt(row: Int, file: Int) {
        let figureAtTarget = figuresDict[row]?[file];
        if figureAtTarget != nil {
            let index = figures.firstIndex(where: {f in f == figureAtTarget! })
            if index != nil {
                figures.remove(at: index!)
            }
        }
    }
    
    private func isMoveInBoard(_ move:Move) -> Bool {
        return 1...8 ~= move.row && 1...8 ~= move.file
    }
    
    private func isMovePossible( _ move: Move, forPiece: Figure) -> Bool {
        switch forPiece.type {
        case .pawn:
            return isLegalPawnMove(forPiece, move)
        case .king:
            return islegalKingMove(forPiece, move)
        case .bishop, .knight, .rook, .queen:
            return isLegalMove(forPiece, move)
        }
    }
    
    private func isLegalPawnMove(_ forPiece: Figure, _ move: Move) -> Bool {
        if figuresDict[move.row]?[move.file] != nil {
            return forPiece.file != move.file && abs(forPiece.file-move.file) <= 1
        }
        let possibleMoves = forPiece.getPossibleMoves()
        return possibleMoves.contains(where:{ m in m == move}) && abs(move.row - forPiece.row) <= 2 && move.file == forPiece.file
    }
    
    private func islegalKingMove(_ piece:Figure, _ move:Move) -> Bool {
        // ToDo: Castle
        return isLegalMove(piece, move)
    }
    
    private func isLegalMove(_ piece: Figure, _ move: Move) -> Bool {
        let intersectingPiece = getIntersectingPiece(piece, move)
        if intersectingPiece != nil {
            return piece.color != intersectingPiece!.color && intersectingPiece!.row == move.row && intersectingPiece!.file == move.file
        }
        
        let possiblePeaceMoves = piece.getPossibleMoves()
        return possiblePeaceMoves.contains(where:{ m in m == move})
    }
    
    private func getIntersectingPiece(_ piece: Figure, _ move: Move) -> Figure? {
        let deltaFile = abs(piece.file - move.file)
        let deltaRow = abs(piece.row - move.row)
        
        if deltaRow == 0 {
            return getIntersectingPieceOnRow(piece, move)
        } else if deltaFile == 0 {
            return getIntersectingPieceOnFile(piece, move)
        } else if deltaRow == deltaFile {
            return getIntersectingPieceOnDiagonal(move, piece)
        } else if piece.type == .knight {
            return getIntersectingPieceForKnight(move, piece)
        }
        return nil
    }
    
    private func getIntersectingPieceOnRow(_ piece: Figure, _ move: Move) -> Figure? {
        let start = min(piece.file, move.file)
        let stop = max(piece.file, move.file)
        for f in start...stop {
            let foundPiece = figuresDict[piece.row]?[f];
            if foundPiece != nil && foundPiece! != piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnFile(_ piece: Figure, _ move: Move) -> Figure? {
        let start = min(piece.row, move.row)
        let stop = max(piece.row, move.row)
        for r in start...stop {
            let foundPiece = figuresDict[r]?[piece.file]
            if foundPiece != nil && foundPiece! != piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceOnDiagonal(_ move: Move, _ piece: Figure) -> Figure? {
        let rowDir = min(max(move.row - piece.row, -1), 1)
        let fileDir = min(max(move.file - piece.file, -1), 1)
        let delta = abs(piece.file - move.file)
        for i in 1...delta {
            let foundPiece = figuresDict[piece.row+(i*rowDir)]?[piece.file+(i*fileDir)]
            if foundPiece != nil && foundPiece! != piece {
                return foundPiece
            }
        }
        return nil
    }
    
    private func getIntersectingPieceForKnight(_ move: Move, _ piece: Figure) -> Figure? {
        return figuresDict[move.row]?[move.file]
    }
    
    private func recreateFiguresCache(){
        var dict:[Int:[Int:Figure]] = [:]
        for f in figures {
            if dict[f.row] == nil {
                dict[f.row] = [:]
            }
            dict[f.row]![f.file] = f
        }
        figuresDict = dict
    }
}
