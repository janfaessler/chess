import SwiftUI
import SwiftChessCore

@Observable
class BoardModel {

    private let logger = Log.logger("BoardModel")

    let gameEvents: AsyncStream<GameEvent>
    private let gameEventContinuation: AsyncStream<GameEvent>.Continuation

    var figures: [PieceModel] = []
    var focus: PieceModel?
    var result: ResultModel
    var moveToPromote: Move?
    var orientation: BoardOrientation = BoardOrientation(isFlipped: false)

    private var pgnHighlights: [SquareHighlight] = []
    private var pgnArrows: [BoardArrow] = []
    private(set) var userHighlights: [SquareHighlight] = []
    private(set) var userArrows: [BoardArrow] = []

    var allHighlights: [SquareHighlight] { pgnHighlights + userHighlights }
    var allArrows: [BoardArrow] { pgnArrows + userArrows }

    private var game: ChessGame

    private static let highlightColorCycle: [AnnotationColor] = [.green, .yellow, .red, .blue]

    init(_ position: Position? = nil) {
        let position = position ?? PositionFactory.startingPosition()
        let game = ChessGame(position)
        self.game = game
        result = ResultModel(game.getGameState())
        (gameEvents, gameEventContinuation) = AsyncStream.makeStream(of: GameEvent.self)
        figures = getFigures()
    }

    var promotionColor: PieceColor {
        moveToPromote?.piece.color ?? .white
    }

    var shouldShowPromotionView: Bool {
        moveToPromote != nil
    }

    func move(figure: PieceModel, deltaRow: Int, deltaFile: Int) {
        guard figure.color == game.colorToMove else {
            logger.error("MOVE REJECTED: color mismatch — figure=\(String(describing: figure.color)) board=\(String(describing: self.game.colorToMove))")
            return
        }

        guard let move = figure.getMove(deltaRow: deltaRow, deltaFile: deltaFile) else {
            logger.error("MOVE REJECTED: no legal move found for \(String(describing: figure.type)) at row=\(figure.row) file=\(figure.file) delta=(\(deltaRow),\(deltaFile))")
            return
        }

        if move.type == .promotion {
            moveToPromote = move
        } else {
            do {
                try doMove(move)
            } catch {
                logger.error("MOVE FAILED: \(error)")
            }
        }
    }

    func doPromote(_ to: PromotionPiece) throws {
        guard let move = moveToPromote else { return }
        try doMove(Move(move, promoteTo: to))
        moveToPromote = nil
    }

    func getLegalMoves() -> [Move] {
        if let focus = focus {
            return game.getPossibleMoves(forPiece: focus.getPiece())
        }
        return []
    }

    func setFocus(_ fig: PieceModel) {
        focus = fig
    }

    func clearFocus() {
        focus = nil
    }

    func toggleOrientation() {
        orientation = BoardOrientation(isFlipped: !orientation.isFlipped)
        figures.forEach { $0.orientation = orientation }
    }

    var position: Position {
        self.game.position
    }

    func updatePosition(_ pos: Position) {
        self.game = ChessGame(pos)
        self.figures = self.getFigures()
        self.result = ResultModel(self.game.getGameState())
    }

    func updateAnnotations(highlights: [SquareHighlight], arrows: [BoardArrow]) {
        self.pgnHighlights = highlights
        self.pgnArrows = arrows
    }

    func toggleUserHighlight(square: String) {
        if let idx = userHighlights.firstIndex(where: { $0.square == square }) {
            let currentColor = userHighlights[idx].color
            let cycleIdx = Self.highlightColorCycle.firstIndex(of: currentColor)
            if let cycleIdx, cycleIdx + 1 < Self.highlightColorCycle.count {
                userHighlights[idx] = SquareHighlight(color: Self.highlightColorCycle[cycleIdx + 1], square: square)
            } else {
                userHighlights.remove(at: idx)
            }
        } else {
            userHighlights.append(SquareHighlight(color: .green, square: square))
        }
    }

    func toggleUserArrow(from: String, to: String, color: AnnotationColor) {
        if let idx = userArrows.firstIndex(where: { $0.from == from && $0.to == to }) {
            if userArrows[idx].color == color {
                userArrows.remove(at: idx)
            } else {
                userArrows[idx] = BoardArrow(color: color, from: from, to: to)
            }
        } else {
            userArrows.append(BoardArrow(color: color, from: from, to: to))
        }
    }

    func clearUserAnnotations() {
        userHighlights.removeAll()
        userArrows.removeAll()
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

    private func getFigures() -> [PieceModel] {
        let orientation = self.orientation
        return self.game.figures.map { [weak self] figure in
            PieceModel(figure, orientation: orientation) { [weak self] event in
                switch event {
                case .moved(let fig, let dRow, let dFile): self?.move(figure: fig, deltaRow: dRow, deltaFile: dFile)
                case .focusSet(let fig): self?.setFocus(fig)
                case .focusCleared: self?.clearFocus()
                }
            }
        }
    }

    private func notifyMoveDone(_ move: Move, positionBeforeMove: Position) {
        let notation = NotationFactory.generate(move, position: positionBeforeMove)
        gameEventContinuation.yield(.moveMade(notation: notation, color: move.piece.color))
    }
}
