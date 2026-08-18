import SwiftUI
import os

@Observable
@MainActor
class ControlModel {

    private let logger = Log.logger("ControlModel")

    var lines: [EngineLine] = []
    var game: PgnGame?

    var comment: String {
        moveList.currentMove?.note ?? (game?.comment ?? "")
    }

    var board: BoardModel
    var moveList = MoveListModel()

    var engine: any EngineProtocol

    private var observationTasks: [Task<Void, Never>] = []
    private var isStarted = false

    init(_ game: PgnGame) {
        self.game = game

        if let fen = TestSupport.boardFen, let position = try? FenParser.parse(fen) {
            board = BoardModel(game: ChessGame(position))
        } else {
            board = BoardModel()
        }

        engine = TestSupport.isUITesting ? StubEngine() : ChessEngine()
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true

        openGame()
        observeBoardMoves()
        observePositionChanges()
        observeEngineEval()

        if TestSupport.isUITesting {
            engine.newPosition(board.position)
        }
    }

    isolated deinit {
        observationTasks.forEach { $0.cancel() }
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

    private func movePlayed(_ notation: String) {
        self.logger.info("movePlayed: \(notation)")
        let position = self.board.position
        let color: PieceColor = position.colorToMove == .white ? .black : .white
        self.moveList.movePlayed(notation, color: color)
        self.engine.newPosition(position)
    }
    
    private func observePositionChanges() {
        let stream = moveList.positionChanged
        observationTasks.append(Task { @MainActor [weak self] in
            for await position in stream {
                self?.positionChange(position)
            }
        })
    }

    private func positionChange(_ position: Position) {
        self.logger.info("positionChange")
        self.board.updatePosition(position)
        self.engine.newPosition(position)
    }
    
    private func observeEngineEval() {
        let stream = engine.evalStream
        observationTasks.append(Task { @MainActor [weak self] in
            for await lines in stream {
                self?.updateEval(lines)
            }
        })
    }

    private func updateEval(_ lines: [EngineLine]) {
        self.logger.info("updateEval \(lines)")
        self.lines = lines
    }
}
