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
        guard let lastMove = getPreviousMove() else { return }
        currentMove = lastMove.id
        updatePosition()
    }
    
    func forward() {
        guard let nextMove = getNextMove() else { return }
        currentMove = nextMove.id
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
        let notations = getMoveNotations(getPlayedMoves())
        return Pgn.loadPosition(notations)
    }
    
    func isCurrentMove(_ id:UUID) -> Bool {
        currentMove == id
    }
    
    func getMoveDescription(_ id:UUID) -> String {
        guard let moveContainer = getMoveContainer(withId: id) else { return "???" }
        return moveContainer.move.info()
    }
    
    func addPositionChangeListener(_ listener:@escaping PositionChangeNotification) {
        positionChangeNotification += [listener]
    }
    
    private func getPreviousMove() -> MoveContainer? {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == currentMove}) else { return nil }
        guard moveIndex > 0 else { return nil }
        return moves[moves.index(before: moveIndex)]
    }
    
    private func getNextMove() -> MoveContainer? {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == currentMove}) else { return nil }
        let nextMoveIndex = moves.index(after: moveIndex)
        guard moves.count > nextMoveIndex else { return  nil}
        return moves[nextMoveIndex]
    }
    
    private func getPlayedMoves() -> [MoveContainer] {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == currentMove}) else { return [] }
        return Array(moves[0..<moveIndex])
    }
    
    private func getMoveContainer(withId:UUID) -> MoveContainer? {
        guard let moveIndex = moves.firstIndex(where: { move in move.id == withId}) else { return nil }
        return moves[moveIndex]
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
    private func getMoveNotations(_ moves:[MoveContainer]) -> [String] {
        return moves.map({ $0.move.info() })
    }
}
