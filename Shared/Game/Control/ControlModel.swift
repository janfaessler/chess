import SwiftUI
import os

public class ControlModel : ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ControlModel")

    private let minControlWidth:CGFloat = 200

    @Published var engineEval:String = ""
    @Published var lines:[EngineLine] = []
    @Published var games:[PgnGame] = []
    
    @Published var game:PgnGame? = nil
    @Published var comment:String = ""

    @ObservedObject var board = BoardModel()
    @ObservedObject var moveList = MoveListModel()
    
    private var engine:ChessEngine = ChessEngine()

    init(_ game:PgnGame) {
        self.game = game
        engine.addEvalListener(updateEval)
        board.addMoveListener(movePlayed)
        moveList.addPositionChangeListener(positionChange)
        openGame()
    }
    
    func getBoardSize(_ geo:GeometryProxy) -> CGFloat {
        return min(geo.size.width - minControlWidth, geo.size.height)
    }

    func openGame() {
        guard let game = game else { return }
        let structure = StructureFactory.create(game)
        moveList.load(structure)
        comment = game.comment ?? ""
    }
    
    private func updatePosition() {
        guard let newPosition = moveList.getPosition() else { return }
        board.updatePosition(newPosition)
        comment = moveList.currentMove?.note ?? ""
        engine.newPosition(newPosition)
    }
    
    private func movePlayed(_ notation:String) {
        moveList.movePlayed(notation)
        comment = moveList.currentMove?.note ?? ""
        engine.newPosition(board.getPosition())
    }
    
    private func positionChange(_ pos:Position) {
        board.updatePosition(pos)
        comment = moveList.currentMove?.note ?? ""
        engine.newPosition(pos)
    }
    
    private func updateEval(_ eval:[EngineLine]) {
        self.lines.removeAll()
        self.lines.append(contentsOf: eval)
    }
}
