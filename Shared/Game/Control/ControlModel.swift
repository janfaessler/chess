import SwiftUI
import SwiftChessCore

@Observable
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

    init(_ game: GameData, engine: (any EngineProtocol)? = nil, settings: EngineSettings = EngineSettings()) {
        self.game = game
        self.settings = settings

        if let fen = TestSupport.boardFen, let position = try? FenParser.parse(fen) {
            board = BoardModel(position)
        } else {
            board = BoardModel()
        }
        self.engine = engine ?? ChessEngine(settings: settings)
    }

    func start() {
        guard !isStarted else { return }
        isStarted = true

        observeBoardMoves()
        observePositionChanges()
        observeEngineEval()

        guard let game else { return }
        isLoading = true
        Task(name: "ControlModel.StructureFactory.create"){ [weak self, game] in
            let structure = StructureFactory.create(game)
            self?.updateStructure(structure)
        }
    }

    isolated deinit {
        observationTasks.forEach { $0.cancel() }
    }
    
    private func updateStructure(_ structure:MoveStructure) {
        self.moveList.load(structure)
        self.isLoading = false
    }

    private func observeBoardMoves() {
        let stream = board.gameEvents
        observationTasks.append(Task(name: "Board.gameEvents") { @concurrent [weak self] in
            for await event in stream {
                if case .moveMade(let notation, let color) = event {
                    await self?.movePlayed(notation, color: color)
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
        observationTasks.append(Task(name:"MoveList.positionChanged") { @concurrent [weak self] in
            for await position in stream {
                await self?.positionChange(position)
            }
        })
    }

    private func positionChange(_ position: Position) {
        self.logger.info("positionChange: \(FenBuilder.create(position))")
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
        observationTasks.append(Task(name:"Engine.evalStream") { @concurrent [weak self] in
            for await lines in stream {
                 await self?.updateEval(lines)
            }
        })
    }

    private func updateEval(_ lines: [EngineLine]) {
        self.lines = lines
    }
}
