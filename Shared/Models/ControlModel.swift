import Foundation
import os

public class ControlModel : ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ControlModel")

    @Published var currentMove:Int = 0
    @Published var board:BoardModel
    @Published var moves:[String] = []
    @Published var engineEval:String = ""
    @Published var lines:[EngineLine] = []

    var engine:ChessEngine
    
    
    init() {
        engine = ChessEngine()
        board = BoardModel()
        engine.addEvalListener(updateEval)
        board.addMoveListener(movePlayed)
    }

    func getMoves() -> [String] {
        return moves
    }
    
    func start() {
        currentMove = 0
        updatePosition()
    }
    
    func back() {
        if currentMove > 0 {
            currentMove -= 1
            updatePosition()
        }
    }
    
    func forward() {
        if currentMove < moves.count {
            currentMove += 1
            updatePosition()
        }
    }
    
    func end() {
        currentMove = moves.count
        updatePosition()
    }
    
    func goToMove(_ index:Int) {
        currentMove = index
        updatePosition()
    }
    
    private func updatePosition() {
        guard let newPosition = Pgn.loadPosition(Array(moves[0..<currentMove])) else { return }
        board.updatePosition(newPosition)
        engine.newPosition(newPosition)
    }
    
    private func movePlayed(_ move:String) {
        moves += [board.getMoveLog().last!]
        currentMove += 1
        engine.newPosition(board.getPosition())
    }
    
    private func updateEval(_ eval:[EngineLine]) {
        self.lines.removeAll()
        self.lines.append(contentsOf: eval)
    }
}
