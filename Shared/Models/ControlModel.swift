import Foundation

public class ControlModel : ObservableObject {
    @Published var board:BoardModel
    @Published var positions:[String] = []
    
    init() {
        board = BoardModel()
        board.addMoveListener(movePlayed)
    }

    func getMoves() -> [String] {
        return board.getMoveLog()
    }
    
    private func movePlayed(_ move:String) {
        positions = getMoves()
        
    }
}
