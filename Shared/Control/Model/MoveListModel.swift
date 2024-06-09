import Foundation

public class MoveListModel : ObservableObject {
    
    typealias PositionChangeNotification = (Position) -> ()
    private var positionChangeNotification:[PositionChangeNotification] = []
    
    @Published var moves:[MoveContainer] = []
    @Published var currentMove:UUID?
    
    var moveCount:Int {
        let moveCount = Float(moves.count / 2)
        let roundedCount = moveCount.rounded(.up)
        let result = Int(roundedCount) + moves.count % 2
        return result
    }
    
    func start() {
        currentMove = moves.first?.id
        updatePosition()
    }
    
    func back() {
        guard currentMove != nil else { return }
        guard let moveIndex = moves.firstIndex(where: { move in move.id == currentMove}) else { return }
        guard moveIndex > 0 else { return }
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
    
    func getRowDescriptionText(_ id:UUID) -> String {
        guard let index = moves.firstIndex(where: { move in move.id == id}) else { return "??" }
        return "\(index / 2 + 1)."
    }
    
    func getMove(_ number:Int, color:PieceColor) -> MoveContainer {
        let moveIndex = getMoveIndex(number, color: color)
        return moves[moveIndex]
    }
    
    func hasMoved(_ number:Int, color:PieceColor) -> Bool {
        let moveIndex = getMoveIndex(number, color: color)
        return moves.count > moveIndex
    }
    
    func movePlayed(_ move:Move) {
        let moveCountainer = MoveContainer(move: move)
        moves += [moveCountainer]
        currentMove = moveCountainer.id
    }
    
    func getPosition() -> Position? {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == currentMove}) else { return nil }
        guard let newPosition = Pgn.loadPosition(Array(moves.map({ $0.move.info() })[0..<moveIndex])) else { return nil }
        return newPosition
    }
    
    func isCurrentMove(_ id:UUID) -> Bool {
        currentMove == id
    }
    
    func getMoveDescription(_ id:UUID) -> String {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == id}) else { return "???" }
        return moves[moveIndex].move.info()
    }
    
    func addPositionChangeListener(_ listener:@escaping PositionChangeNotification) {
        positionChangeNotification += [listener]
    }
    
    private func getMoveIndex(_ number:Int, color:PieceColor) -> Int {
        if color == .white {
            if number == 1 {
                return number - 1
            }
            return number * 2 - 2
        } else {
            if number == 1 {
                return number
            }
            return number * 2 - 1
        }
    }
    
    private func updatePosition()  {
        guard let position = getPosition() else { return }
        for event in positionChangeNotification {
            event(position)
        }
    }
}
