import SwiftUI
import os

@Observable
class BoardModel {
    
    typealias MoveNotification = (String) -> ()
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "BoardModel")
    private var moveNotifications: [MoveNotification] = []
    
    var figures: [FigureModel] = []
    var focus: FigureModel?
    var result: ResultModel
    var moveToPromote: Move?
    
    private var board: ChessBoard


    init(board: ChessBoard? = nil) {
        let newBoard = board ?? ChessBoard(PositionFactory.startingPosition())
        self.board = newBoard
        result = ResultModel(newBoard.getGameState())
        figures = getFigures()
    }
    
    
    var promotionColor: PieceColor {
        moveToPromote!.piece.getColor()
    }
    
    var shouldShowPromotionView: Bool {
        moveToPromote != nil
    }
    
    func move(figure: FigureModel, deltaRow: Int, deltaFile: Int) {
        guard figure.getColor() == board.getColorToMove() else {
            logger.error("MOVE REJECTED: color mismatch — figure=\(String(describing: figure.getColor())) board=\(String(describing: self.board.getColorToMove()))")
            return
        }

        guard let move = figure.getMove(deltaRow: deltaRow, deltaFile: deltaFile) else {
            logger.error("MOVE REJECTED: no legal move found for \(String(describing: figure.getType())) at row=\(figure.row) file=\(figure.file) delta=(\(deltaRow),\(deltaFile))")
            return
        }
        
        if move.type == .Promotion {
            moveToPromote = move
        } else {
            try? doMove(move)
        }
    }
    
    func doPromote(_ to: PieceType) throws {
        guard var move = moveToPromote else { return }
        move.promoteTo = to
        try doMove(move)
        moveToPromote = nil
    }
    
    func getLegalMoves() -> [Move] {
        if let focus = focus {
            return board.getPossibleMoves(forPiece: focus.getFigure())
        }
        return []
    }
    
    func setFocus(_ fig: FigureModel) {
        focus = fig
    }
    
    func clearFocus() {
        focus = nil
    }
    
    func getPosition() -> Position {
        self.board.getPosition()
    }
    
    func addMoveListener(_ listener: @escaping MoveNotification) {
        self.moveNotifications.append(listener)
    }
    
    func updatePosition(_ pos: Position) {
        self.logger.info("BoardModel.updatePosition called - updating \(pos.getFigures().count) figures")
        self.board = ChessBoard(pos)
        let newFigures = self.getFigures()
        self.figures = newFigures
        self.result = ResultModel(self.board.getGameState())
        self.logger.info("BoardModel.updatePosition complete - now have \(self.figures.count) figures")
    }
    
    func moveFocusFigureTo(_ location: CGPoint, fieldSize: CGFloat) {
        guard let figure = self.focus else { return }

        let row = Int(9 - location.y / fieldSize)
        let file = Int(1 + location.x / fieldSize)
        let deltarow = row - figure.row
        let deltafile = file - figure.file
        
        self.move(figure: figure, deltaRow: deltarow, deltaFile: deltafile)
        self.clearFocus()
    }
    
    private func doMove(_ move: Move) throws {
        let positionBeforeMove = FenBuilder.create(self.board.getPosition())
        try self.board.move(move)
        self.figures = self.getFigures()
        self.result = ResultModel(self.board.getGameState())
        self.logger.info("doMove succeeded, colorToMove now=\(String(describing: self.board.getColorToMove()))")
        self.notifyMoveDone(move, fen: positionBeforeMove)
    }
    
    private func getFigures() -> [FigureModel] {
        let figures = self.board.getFigures()
        return figures.map { FigureModel($0, board: self) }
    }
    
    private func notifyMoveDone(_ move: Move, fen: String) {
        let notation = NotationFactory.generate(move, position: FenParser.parse(fen))
        for event in self.moveNotifications {
            event(notation)
        }
    }
}
