import SwiftUI
import os

public class ControlModel : ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ControlModel")
    private let minControlWidth:CGFloat = 200

    @Published var currentMove:Int = 0
    @Published var moves:[String] = []
    @Published var engineEval:String = ""
    @Published var lines:[EngineLine] = []
    
    @ObservedObject var board = BoardModel()
    private var engine:ChessEngine = ChessEngine()
    

    init() {
        engine.addEvalListener(updateEval)
        board.addMoveListener(movePlayed)
    }
    
    var navigationbuttonSize:CGSize {
        CGSize(width: minControlWidth / 4, height: 30)
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
    
    func getBoardSize(_ geo:GeometryProxy) -> CGFloat {
        return min(geo.size.width - minControlWidth, geo.size.height)
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
