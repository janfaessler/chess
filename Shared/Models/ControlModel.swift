import Foundation

public class ControlModel : ObservableObject {
    
    @Published var currentMove:Int = 0
    @Published var board:BoardModel
    @Published var moves:[String] = []
    
    init() {
        board = BoardModel()
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
    
    private func updatePosition() {
        guard let newPosition = Pgn.loadPosition(Array(moves[0..<currentMove])) else { return }
        board.updatePosition(newPosition)
    }
    
    private func movePlayed(_ move:String) {
        moves += [board.getMoveLog().last!]
        currentMove += 1
    }
}
