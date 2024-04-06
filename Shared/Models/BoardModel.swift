import SwiftUI
import os

class BoardModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BoardModel")
    
    typealias MoveNotification = (String) -> ()
    private var moveNotifcations:[MoveNotification] = []
    
    @Published var figures:[FigureModel] = []
    @Published var focus:FigureModel?
    @Published var result:ResultModel
    @Published var moveToPromote:Move?
    
    private var board:ChessBoard

    init() {
        board = ChessBoard(Fen.loadStartingPosition())
        result = ResultModel(board.getGameState())
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
        
        if move.type == .Promotion {
            moveToPromote = move
        } else {
            try doMove(move)
        }
    }
    

    
    func doMove(_ move: Move) throws {
        try board.move(move)
        notifyMoveDone(move.info())
        figures = getFigures()
        result = ResultModel(board.getGameState())
    }
    
    func doPromote(_ to:PieceType) throws {
        moveToPromote?.promoteTo = to
        try doMove(moveToPromote!)
        moveToPromote = nil
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
    
    func moveFocusFigureTo(row: Int, file:Int) throws {
        guard let figure = focus else { return }
        let deltarow = row - figure.row
        let deltafile = file - figure.file
        try move(figure: figure, deltaRow: deltarow, deltaFile: deltafile)
        clearFocus()
    }
    
    func shouldShowPromotionView() -> Bool {
        return moveToPromote != nil
    }
    
    func getPosition() -> Position {
        return board.getPosition()
    }
    
    func getMoveLog() -> [String] {
        return board.getMoveLog()
    }
    
    func addMoveListener(_ listener:@escaping MoveNotification) {
        moveNotifcations += [listener]
    }
    
    func updatePosition(_ pos:Position)  {
        board = ChessBoard(pos)
        figures = getFigures()

    }
    
    private func moveAndUpdateModel(_ move: Move) throws {
        try board.move(move)
        figures = getFigures()
        result = ResultModel(board.getGameState())
    }
    
    private func getFigures() -> [FigureModel] {
        let figures = board.getFigures()
        return figures.map({ FigureModel($0) })
    }
    
    private func notifyMoveDone(_ move:String) {
        for event in moveNotifcations {
            event(move)
        }
    }
}
