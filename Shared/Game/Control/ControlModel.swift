import SwiftUI
import os

@Observable
class ControlModel {

    private let logger = Log.logger("ControlModel")
    private let minControlWidth: CGFloat = 200

    var engineEval: String = ""
    var lines: [EngineLine] = []
    var game: PgnGame?

    var comment: String {
        moveList.currentMove?.note ?? (game?.comment ?? "")
    }
    var eval:[EngineLine] {
        engine.lines
    }

    var board = BoardModel()
    var moveList = MoveListModel()

    var engine = ChessEngine()

    init(_ game: PgnGame) {
        self.game = game
        engine.addEvalListener(updateEval)
        board.addMoveListener(movePlayed)
        moveList.addPositionChangeListener(positionChange)
        openGame()
    }

    func getBoardSize(_ geo: GeometryProxy) -> CGFloat {
        min(geo.size.width - minControlWidth, geo.size.height)
    }

    func openGame() {
        guard let game = game else { return }
        let structure = StructureFactory.create(game)
        moveList.load(structure)
    }

    private func movePlayed(_ notation: String) {
        self.logger.info("movePlayed: \(notation)")
        let position = self.board.getPosition()
        let color: PieceColor = position.getColorToMove() == .white ? .black : .white
        self.moveList.movePlayed(notation, color: color)
        self.engine.newPosition(position)
    }

    private func positionChange(_ position: Position) {
        self.logger.info("positionChange")
        self.board.updatePosition(position)
        self.engine.newPosition(position)
    }

    private func updateEval(_ lines: [EngineLine]) {
        self.logger.info("updateEval \(lines)")
        self.lines = lines
        engineEval = lines.debugDescription
    }
}
