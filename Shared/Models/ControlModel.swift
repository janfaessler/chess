import SwiftUI

public class ControlModel : ObservableObject {
    private let minControlWidth:CGFloat = 200

    @Published var currentMove:Int = 0
    @Published var realMoves:[Move] = []
    @Published var engineEval:String = ""
    @Published var lines:[EngineLine] = []
    
    @ObservedObject var board = BoardModel()
    private var engine:ChessEngine = ChessEngine()
    

    init() {
        engine.addEvalListener(updateEval)
        board.addMoveListener(movePlayed)
    }
    
    var moveListColumns:[GridItem] {
        [GridItem(.fixed(20)), GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var navigationbuttonSize:CGSize {
        CGSize(width: minControlWidth / 4, height: 30)
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
        if currentMove < realMoves.count {
            currentMove += 1
            updatePosition()
        }
    }
    
    func end() {
        currentMove = realMoves.count
        updatePosition()
    }
    
    func goToMove(_ index:Int) {
        currentMove = index
        updatePosition()
    }
    
    func getBoardSize(_ geo:GeometryProxy) -> CGFloat {
        return min(geo.size.width - minControlWidth, geo.size.height)
    }
    
    func isCurrentMove(_ index:Int) -> Bool {
        currentMove == (index + 1)
    }
    
    func getMoveDescription(_ index:Int) -> String {
        realMoves[index].info()
    }
    
    func isNewRow(_ index:Int) -> Bool {
        index % 2 == 0
    }
    
    func getRowDescriptionText(_ index:Int) -> String {
        "\(index / 2 + 1)."
    }
    
    private func updatePosition() {
        guard let newPosition = Pgn.loadPosition(Array(realMoves.map({ $0.info() })[0..<currentMove])) else { return }
        board.updatePosition(newPosition)
        engine.newPosition(newPosition)
    }
    
    private func movePlayed(_ move:String) {
        realMoves += [board.getMoves().last!]
        currentMove += 1
        engine.newPosition(board.getPosition())
    }
    
    private func updateEval(_ eval:[EngineLine]) {
        self.lines.removeAll()
        self.lines.append(contentsOf: eval)
    }
}
