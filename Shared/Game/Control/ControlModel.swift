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

    private var observationTasks: [Task<Void, Never>] = []

    init(_ game: PgnGame) {
        self.game = game
        engine.addEvalListener(updateEval)
        openGame()
        observeBoardMoves()
        observePositionChanges()
    }

    deinit {
        observationTasks.forEach { $0.cancel() }
    }

    func getBoardSize(_ geo: GeometryProxy) -> CGFloat {
        min(geo.size.width - minControlWidth, geo.size.height)
    }

    func openGame() {
        guard let game = game else { return }
        let structure = StructureFactory.create(game)
        moveList.load(structure)
    }

    private func observeBoardMoves() {
        let stream = board.movePlayed
        observationTasks.append(Task { @MainActor [weak self] in
            for await notation in stream {
                self?.movePlayed(notation)
            }
        })
    }

    private func observePositionChanges() {
        let stream = moveList.positionChanged
        observationTasks.append(Task { @MainActor [weak self] in
            for await position in stream {
                self?.positionChange(position)
            }
        })
    }

    private func movePlayed(_ notation: String) {
        self.logger.info("movePlayed: \(notation)")
        let position = self.board.position
        let color: PieceColor = position.colorToMove == .white ? .black : .white
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
