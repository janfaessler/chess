import SwiftUI
import SwiftChessCore

@Observable
class BoardModel {
    
    private let logger = Log.logger("BoardModel")

    let movePlayed: AsyncStream<String>
    private let moveContinuation: AsyncStream<String>.Continuation

    var figures: [FigureModel] = []
    var focus: FigureModel?
    var result: ResultModel
    var moveToPromote: Move?
    var orientation: BoardOrientation = BoardOrientation(isFlipped: false)

    private var game: ChessGame


    init(_ position: Position? = nil) {
        let position = position ?? PositionFactory.startingPosition()
        let game = ChessGame(position)
        self.game = game
        result = ResultModel(game.getGameState())
        (movePlayed, moveContinuation) = AsyncStream.makeStream(of: String.self)
        figures = getFigures()
    }
    
    
    var promotionColor: PieceColor {
        moveToPromote?.piece.color ?? .white
    }
    
    var shouldShowPromotionView: Bool {
        moveToPromote != nil
    }
    
    func move(figure: FigureModel, deltaRow: Int, deltaFile: Int) {
        guard figure.color == game.colorToMove else {
            logger.error("MOVE REJECTED: color mismatch — figure=\(String(describing: figure.color)) board=\(String(describing: self.game.colorToMove))")
            return
        }

        guard let move = figure.getMove(deltaRow: deltaRow, deltaFile: deltaFile) else {
            logger.error("MOVE REJECTED: no legal move found for \(String(describing: figure.type)) at row=\(figure.row) file=\(figure.file) delta=(\(deltaRow),\(deltaFile))")
            return
        }
        
        if move.type == .Promotion {
            moveToPromote = move
        } else {
            do {
                try doMove(move)
            } catch {
                logger.error("MOVE FAILED: \(error)")
            }
        }
    }
    
    func doPromote(_ to: PieceType) throws {
        guard let move = moveToPromote else { return }
        try doMove(Move(move, promoteTo: to))
        moveToPromote = nil
    }
    
    func getLegalMoves() -> [Move] {
        if let focus = focus {
            return game.getPossibleMoves(forPiece: focus.getFigure())
        }
        return []
    }
    
    func setFocus(_ fig: FigureModel) {
        focus = fig
    }
    
    func clearFocus() {
        focus = nil
    }
    
    func toggleOrientation() {
        orientation = BoardOrientation(isFlipped: !orientation.isFlipped)
    }

    var position: Position {
        self.game.position
    }

    func updatePosition(_ pos: Position) {
        self.game = ChessGame(pos)
        let newFigures = self.getFigures()
        self.figures = newFigures
        self.result = ResultModel(self.game.getGameState())
    }
    
    func moveFocusFigureTo(_ location: CGPoint, fieldSize: CGFloat) {
        guard let figure = self.focus else { return }

        let row = orientation.logicalRow(y: location.y, fieldSize: fieldSize)
        let file = orientation.logicalFile(x: location.x, fieldSize: fieldSize)
        let deltarow = row - figure.row
        let deltafile = file - figure.file

        self.move(figure: figure, deltaRow: deltarow, deltaFile: deltafile)
        self.clearFocus()
    }

    func playFocusFigureMove(_ move: Move) {
        guard let figure = self.focus else { return }
        self.move(figure: figure, deltaRow: move.row - figure.row, deltaFile: move.file - figure.file)
        self.clearFocus()
    }
    
    private func doMove(_ move: Move) throws {
        let positionBeforeMove = self.game.position
        try self.game.move(move)
        self.figures = self.getFigures()
        self.result = ResultModel(self.game.getGameState())
        self.notifyMoveDone(move, positionBeforeMove: positionBeforeMove)
    }

    private func getFigures() -> [FigureModel] {
        let figures = self.game.figures
        return figures.map { FigureModel($0, board: self) }
    }

    private func notifyMoveDone(_ move: Move, positionBeforeMove: Position) {
        let notation = NotationFactory.generate(move, position: positionBeforeMove)
        moveContinuation.yield(notation)
    }
}
