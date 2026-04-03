import SwiftUI
import os

@Observable
public class ControlModel {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ControlModel")
    private let minControlWidth: CGFloat = 200

    var engineEval: String = ""
    var lines: [EngineLine] = []
    var games: [PgnGame] = []
    var game: PgnGame?
    var comment: String = ""

    var board = BoardModel()
    var moveList = MoveListModel()
    
    private var engine: ChessEngine = ChessEngine()

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
        comment = game.comment ?? ""
    }
    
    private func updatePosition() {
        self.logger.info("updatePosition called")
        guard let newPosition = self.moveList.getPosition() else { return }
        self.board.updatePosition(newPosition)
        self.comment = self.moveList.currentMove?.note ?? ""
        self.engine.newPosition(newPosition)
    }
    
    private func movePlayed(_ notation: String) {
        self.logger.info("movePlayed: \(notation)")
        self.moveList.movePlayed(notation)
        self.comment = self.moveList.currentMove?.note ?? ""
        self.engine.newPosition(self.board.getPosition())
    }
    
    private func positionChange(_ pos: Position) {
        self.logger.info("positionChange called - updating board")
        self.board.updatePosition(pos)
        self.comment = self.moveList.currentMove?.note ?? ""
        self.engine.newPosition(pos)
    }
    
    private func updateEval(_ eval: [EngineLine]) {
        self.lines.removeAll()
        self.lines.append(contentsOf: eval)
    }
}
