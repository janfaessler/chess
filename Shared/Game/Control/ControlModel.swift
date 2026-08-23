import SwiftUI
import SwiftChessCore

@Observable
@MainActor
class ControlModel {

    private let logger = Log.logger("ControlModel")

    var lines: [EngineLine] = []
    var game: GameData?

    var comment: String {
        moveList.currentMove?.note ?? (game?.comment ?? "")
    }

    var board: BoardModel
    var moveList = MoveListModel()

    var engine: any EngineProtocol
    let settings: EngineSettings

    private var observationTasks: [Task<Void, Never>] = []
    private var isStarted = false
    var isLoading = false

    init(_ game: GameData, settings: EngineSettings = EngineSettings()) {
        self.game = game
        self.settings = settings

        if let fen = TestSupport.boardFen, let position = try? FenParser.parse(fen) {
            board = BoardModel(position)
        } else {
            board = BoardModel()
        }
        engine = TestSupport.isUITesting ? StubEngine() : ChessEngine(settings: settings)
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true

        observeBoardMoves()
        observePositionChanges()
        observeEngineEval()

        if TestSupport.isUITesting {
            engine.newPosition(board.position)
        }

        guard let game else { return }
        isLoading = true
        Task.detached(priority: .userInitiated) { [weak self, game] in
            let structure = StructureFactory.create(game)
            await MainActor.run { [weak self] in
                self?.moveList.load(structure)
                self?.isLoading = false
            }
        }
    }

    isolated deinit {
        observationTasks.forEach { $0.cancel() }
    }

    private func observeBoardMoves() {
        let stream = board.gameEvents
        observationTasks.append(Task { @MainActor [weak self] in
            for await event in stream {
                if case .moveMade(let notation, let color) = event {
                    self?.movePlayed(notation, color: color)
                }
            }
        })
    }

    private func movePlayed(_ notation: String, color: PieceColor) {
        self.logger.info("movePlayed: \(notation)")
        let position = self.board.position
        self.moveList.movePlayed(notation, color: color)
        self.board.annotations.clearUserAnnotations()
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
        self.board.annotations.clearUserAnnotations()
        self.board.annotations.updatePgn(
            highlights: moveList.currentMove?.highlights ?? [],
            arrows: moveList.currentMove?.arrows ?? []
        )
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
