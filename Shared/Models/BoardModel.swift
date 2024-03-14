import SwiftUI
import os

class BoardModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BoardModel")
    
    @Published var figures:[FigureModel] = []
    @Published var focus:FigureModel?
    
    private var board:ChessBoard

    init() {
        board = ChessBoard(Fen.loadStartingPosition())
        figures = getFigures()
    }
    

    func move(figure: FigureModel, deltaRow:Int, deltaFile:Int)  throws {
        
        guard figure.getColor() == board.getColorToMove() else {
            logger.error("other player has to move first")
            return
        }
        
        guard let move = figure.getMove(deltaRow: deltaRow, deltaFile: deltaFile) else {
            logger.error("no possible move found")
            return
        }
        
        try moveAndUpdateFigures(move)
    }
    
    func getLegalMoves() -> [Move] {
        if focus != nil {
            let moves = board.getPossibleMoves(forPeace: focus!.getFigure())
            return moves
        }
        return []
    }
    
    func setFocus(_ fig: FigureModel) {
        focus = fig
    }
    
    func clearFocus() {
        if focus != nil {
            focus = nil
        }
    }
    
    private func moveAndUpdateFigures(_ move: Move) throws {
        try board.move(move)
        figures = getFigures()
    }
    
    private func getFigures() -> [FigureModel] {
        let figures = board.getFigures()
        return figures.map({ FigureModel($0) })
    }
}
