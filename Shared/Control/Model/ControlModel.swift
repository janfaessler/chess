import SwiftUI

public class ControlModel : ObservableObject {
    private let minControlWidth:CGFloat = 200

    @Published var currentMove:UUID?
    @Published var moves:[MoveContainer] = []
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
        currentMove = moves.first?.id
        updatePosition()
    }
    
    func back() {
        guard currentMove != nil else { return }
        guard let moveIndex = moves.firstIndex(where: { move in move.id == currentMove}) else { return }
        currentMove = moves[moves.index(before: moveIndex)].id
        updatePosition()
    }
    
    func forward() {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == currentMove}) else { return }
        let nextMoveIndex = moves.index(after: moveIndex)
        guard moves.count > nextMoveIndex else { return }
        currentMove = moves[nextMoveIndex].id
        updatePosition()
    }
    
    func end() {
        currentMove = moves.last?.id
        updatePosition()
    }
    
    func goToMove(_ id:UUID) {
        currentMove = id
        updatePosition()
    }
    
    func getBoardSize(_ geo:GeometryProxy) -> CGFloat {
        return min(geo.size.width - minControlWidth, geo.size.height)
    }
    
    func isCurrentMove(_ id:UUID) -> Bool {
        currentMove == id
    }
    
    func getMoveDescription(_ id:UUID) -> String {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == id}) else { return "???" }
        return moves[moveIndex].move.info()
    }
    
    func isNewRow(_ index:Int) -> Bool {
        index % 2 == 0
    }
    
    func getRowDescriptionText(_ id:UUID) -> String {
        guard let index = moves.firstIndex(where: { move in move.id == id}) else { return "??" }
        return "\(index / 2 + 1)."
    }
    
    private func updatePosition() {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == currentMove}) else { return }
        guard let newPosition = Pgn.loadPosition(Array(moves.map({ $0.move.info() })[0..<moveIndex])) else { return }
        board.updatePosition(newPosition)
        engine.newPosition(newPosition)
    }
    
    private func movePlayed(_ move:String) {
        let playedMove = MoveContainer(move:board.getMoves().last!)
        moves += [playedMove]
        currentMove = playedMove.id
        engine.newPosition(board.getPosition())
    }
    
    private func updateEval(_ eval:[EngineLine]) {
        self.lines.removeAll()
        self.lines.append(contentsOf: eval)
    }
}
