import Foundation
import os

public class MoveListModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MoveListModel")
    
    typealias PositionChangeNotification = (Position) -> ()
    private var positionChangeNotification:[PositionChangeNotification] = []
    
    private var history: [MoveContainer] = []
    private var parrentMoves:[UUID:MoveContainer] = [:]
    
    @Published public var moves:[RowContainer] = []
    @Published public var currentMove:MoveContainer?
    
    public init() {}
    
    
    var moveCount:Int {
        let moveCount = Float(moves.count / 2)
        let roundedCount = moveCount.rounded(.up)
        let result = Int(roundedCount) + moves.count % 2
        return result
    }
    
    public func start() {
        history.removeAll()
        currentMove = nil
        updatePosition()
    }
    
    public func back() {
        guard history.isEmpty == false else { return }
        history.removeLast()
        self.currentMove = history.last
        updatePosition()
    }
    
    public func forward() {
        guard let nextMove = getNextMove(currentMove) else { return }
        self.currentMove = nextMove
        updateHistory()
        updatePosition()
    }
    
    public func end() {
        currentMove = moves.last!.hasBlackMoved() ? moves.last!.black : moves.last!.white
        recreateTopLevelHistory()
        updatePosition()
    }
    
    func goToMove(_ move:MoveContainer) {
        currentMove = move
        history.removeAll()
        guard let index = moves.firstIndex(where: { $0.white == currentMove || $0.black == currentMove}) else {
            recreateVariationHistory()
            return
        }
        for row in moves[moves.startIndex...index] {
            history.append(row.white)
            if row.hasBlackMoved() && currentMove != row.white{
                history.append(row.black!)
            }
        }
        updatePosition()
    }
    
    public func movePlayed(_ move:Move) {
        let container = MoveContainer(move: move)

        if isTopLevelMove(container) {
            addTopLevelMove(container)
        } else {
            addVariationMove(container)
        }
    }
    
    func getPosition() -> Position? {
        guard currentMove != nil else { return Fen.loadStartingPosition() }
        let notations = getMoveNotations()
        return Pgn.loadPosition(notations)
    }
    
    func isCurrentMove(_ container:MoveContainer) -> Bool {
        currentMove == container
    }
    
    func getMoveDescription(_ container:MoveContainer) -> String {
        return container.move.info()
    }
    
    func addPositionChangeListener(_ listener:@escaping PositionChangeNotification) {
        positionChangeNotification += [listener]
    }
    
    private func isTopLevelMove(_ container:MoveContainer?) -> Bool {
        guard !moves.isEmpty else { return true }
        guard let container = container else { return true }
        
        if moves.contains(where: { $0.white.id == container.id || $0.black?.id == container.id}) {
            return true
        }
        let currentContainer = moves.first(where: { $0.white == currentMove || $0.black == currentMove})

        return currentContainer == moves.last
    }
    
    private func addTopLevelMove(_ container: MoveContainer) {
        guard moves.count > 0 else {
            moves += [RowContainer(moveNumber: 1, white: container)]
            currentMove = container
            updateHistory()
            return
        }
        if moves[moves.index(before: moves.endIndex)].hasBlackMoved() == true {
            moves += [RowContainer(moveNumber: moves.count + 1, white: container)]
        } else {
            moves[moves.index(before: moves.endIndex)].black = container
        }
        currentMove = container
        updateHistory()
    }
    
    private func addVariationMove(_ container:MoveContainer) {
        guard let lastMove = currentMove else { return }
        let parentMove = parrentMoves[lastMove.id]
        
        let moveInVariation = parentMove?.variations.keys.first(where: { $0 == lastMove.move.info() })
        
        if moveInVariation == nil {
            lastMove.variations[container.move.info()] = [container]
        } else {
            parentMove!.variations[moveInVariation!]?.append(container)
        }
        
        self.currentMove = container
        parrentMoves[container.id] = lastMove
        history.append(container)
    }
    
    private func addVariation(_ move: Move, toMove: inout MoveContainer) {
        let cointainer = MoveContainer(move: move)
        let variation = move.info()
        toMove.variations[variation] = [cointainer]
        self.currentMove = cointainer
        parrentMoves[cointainer.id] = toMove
    }
    
    private func updateHistory() {
        guard let currentMove = currentMove else { return }
        history.append(currentMove)
    }
    
    private func recreateTopLevelHistory() {
        history.removeAll()
        for row in moves {
            history.append(row.white)
            if row.hasBlackMoved() && currentMove != row.white {
                history.append(row.black!)
            }
        }
    }
    
    private func recreateVariationHistory()  {
        history.removeAll()
        var reverseHistory: [MoveContainer] = []

        guard var currentMove = currentMove else { return }
        
        while parrentMoves.keys.contains(where: { $0 == currentMove.id }) {
            guard let parrentMove = parrentMoves[currentMove.id] else { return }
            guard let variationName = parrentMove.getVariation(currentMove) else { return }
            guard let variation = parrentMove.variations[variationName] else { return }
            guard let moveIndex = variation.firstIndex(of: currentMove) else { return }
            for move in variation[variation.startIndex...moveIndex].reversed() {
                reverseHistory.append(move)
            }
            currentMove = parrentMove
        }
        guard let topLevelIndex = moves.firstIndex(where: { $0.white == currentMove || $0.black == currentMove }) else { return }
        for row in moves[moves.startIndex...topLevelIndex].reversed() {
            if row.hasBlackMoved() {
                reverseHistory.append(row.black!)
            }
            reverseHistory.append(row.white)
        }
        
        history.append(contentsOf: reverseHistory.reversed())
    }
    
    private func getNextMove(_ fromContainer:MoveContainer?) -> MoveContainer? {
        guard let fromContainer = fromContainer else {
            return moves.first?.white
        }
        if isTopLevelMove(fromContainer) {
            guard let index = moves.firstIndex(where: { $0.white.id == fromContainer.id || $0.black?.id == fromContainer.id }) else { return nil }
    
            guard fromContainer == moves[index].black else {
                return moves[index].black
            }

            let nextIndex = moves.index(after: index)
            guard nextIndex < moves.count else { return nil }

            return moves[nextIndex].white
        }
        guard let parentMove = parrentMoves[fromContainer.id] else { return nil }
        guard let variation = parentMove.getVariation(fromContainer) else { return nil }
        return getNextMove(fromContainer, inVariation: parentMove.variations[variation]!)
    }
        
    private func getNextMove(_ fromContainer:MoveContainer?, inVariation:[MoveContainer]) -> MoveContainer? {
        guard let fromContainer = fromContainer else { return nil }
        guard let moveIndex = inVariation.firstIndex(where: { $0.id == fromContainer.id}) else { return nil }
        let nextMoveIndex = inVariation.index(after: moveIndex)
        guard inVariation.count > nextMoveIndex else { return  nil}
        return inVariation[nextMoveIndex]
    }
    
    private func getIndex(_ container:MoveContainer, inVariation: [MoveContainer]) -> Int? {
        return inVariation.firstIndex(where: { $0.id == container.id})
    }
    
    private func updatePosition()  {
        guard let position = getPosition() else { return }
        for event in positionChangeNotification {
            event(position)
        }
    }
    
    private func getMoveNotations() -> [String] {
        return history.map({ $0.move.info() })
    }
}
