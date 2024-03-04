//
//  BoardViewModel.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.12.21.
//
import SwiftUI
import os

class BoardModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BoardModel")
    
    @Published var figures:[Figure] = []
    @Published var focus:Figure?
    
    private var board:ChessBoard

    init() {
        board = ChessBoard(Fen.loadStartingPosition())
        figures = board.getFigures()
    }
    

    func move(figure: Figure, deltaRow:Int, deltaFile:Int) {
        
        guard figure.color == board.getColorToMove() else {
            logger.error("other player has to move first")
            return
        }
        
        guard let move = figure.getMove(deltaRow: deltaRow, deltaFile: deltaFile) else {
            logger.error("no possible move found")
            return
        }
        
        moveAndUpdateFigures(move)
    }
    
    func getLegalMoves() -> [Move] {
        if focus != nil {
            let moves = board.getPossibleMoves(forPeace: focus!)
            return moves
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
    
    private func moveAndUpdateFigures(_ move: Move) {
        board.move(move: move)
        figures = board.getFigures()
    }
}
