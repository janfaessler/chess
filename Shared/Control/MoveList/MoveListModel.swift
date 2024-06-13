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
    
    public func goToMove(_ move:MoveContainer) {
        currentMove = move
        history.removeAll()
        guard let index = moves.firstIndex(where: { $0.white == currentMove || $0.black == currentMove}) else {
            recreateVariationHistory()
            return
        }
        for row in moves[moves.startIndex...index] {
            if row.hasWhiteMoved() {
                history.append(row.white!)
            }
            if row.hasBlackMoved() && currentMove != row.white{
                history.append(row.black!)
            }
        }
        updatePosition()
    }
    
    public func movePlayed(_ move:Move) {
        let container = MoveContainer(move: move)
        let blackHasLastTopLevelMove = moves.last?.black != nil

        if (blackHasLastTopLevelMove && currentMove == moves.last?.black) || (!blackHasLastTopLevelMove && moves.last?.white == currentMove) {
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
    
    public func isCurrentMove(_ container:MoveContainer?) -> Bool {
        currentMove == container
    }
    
    func getMoveDescription(_ container:MoveContainer) -> String {
        return container.move.info()
    }
    
    func addPositionChangeListener(_ listener:@escaping PositionChangeNotification) {
        positionChangeNotification += [listener]
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
        let moveInVariation = parentMove?.getVariation(lastMove)
        if moveInVariation == nil {
            addNewVariation(container, to: lastMove)
        } else {
            appendVariation(container, to: parentMove!, variation: moveInVariation!, lastMove: lastMove)
        }
        
        self.currentMove = container
        history.append(container)
    }
    
    private func createRowContainer(_ container: MoveContainer, moveNumber:Int = 1) -> RowContainer {
        var rowContainer:RowContainer
        if container.move.piece.getColor() == .white {
            rowContainer = RowContainer(moveNumber: moveNumber, white: container)
        } else {
            rowContainer = RowContainer(moveNumber: moveNumber, black: container)
        }
        return rowContainer
    }
    
    private func appendVariation(_ container: MoveContainer, to: MoveContainer, variation: String, lastMove: MoveContainer) {
        let rowNumber = (to.variations[variation]?.count ?? 1) + 1
        if container.move.piece.getColor() == .white {
            let rowContainer = createRowContainer(container, moveNumber: rowNumber)
            to.variations[variation]?.append(rowContainer)
        } else {
            if to.variations[variation]!.last?.black == nil {
                to.variations[variation]!.last!.black = container
            } else {
                let rowContainer = createRowContainer(container, moveNumber: rowNumber)
                to.variations[variation]?.append(rowContainer)
            }
        }
        parrentMoves[container.id] = to
    }
    
    private func addNewVariation( _ container: MoveContainer, to: MoveContainer) {
        let rowContainer = createRowContainer(container)
        
        to.variations[container.move.info()] = [rowContainer]
        parrentMoves[container.id] = to
    }
    
    private func updateHistory() {
        guard let currentMove = currentMove else { return }
        history.append(currentMove)
    }
    
    private func recreateTopLevelHistory() {
        history.removeAll()
        for row in moves {
            if row.hasWhiteMoved() {
                history.append(row.white!)
            }
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
            guard let rowIndex = variation.firstIndex(where: { $0.white == currentMove || $0.black == currentMove }) else { return }
            for row in variation[variation.startIndex...rowIndex].reversed() {
                if row.hasBlackMoved() {
                    reverseHistory.append(row.black!)
                }
                if row.hasWhiteMoved() {
                    reverseHistory.append(row.white!)
                }
            }
            currentMove = parrentMove
        }
        guard let topLevelIndex = moves.firstIndex(where: { $0.white == currentMove || $0.black == currentMove }) else { return }
        for row in moves[moves.startIndex...topLevelIndex].reversed() {
            if row.hasBlackMoved() {
                reverseHistory.append(row.black!)
            }
            if row.hasWhiteMoved() {
                reverseHistory.append(row.white!)
            }
        }
        
        history.append(contentsOf: reverseHistory.reversed())
    }
    
    private func getNextMove(_ fromContainer:MoveContainer?) -> MoveContainer? {
        guard let fromContainer = fromContainer else {
            return moves.first?.white
        }
        if !parrentMoves.contains(where: { $0.key == fromContainer.id}) {
            guard let index = moves.firstIndex(where: { $0.white?.id == fromContainer.id || $0.black?.id == fromContainer.id }) else { return nil }
    
            guard fromContainer == moves[index].black else {
                return moves[index].black
            }

            let nextIndex = moves.index(after: index)
            return moves[nextIndex].white
        }
        guard let parentMove = parrentMoves[fromContainer.id] else { return nil }
        guard let variation = parentMove.getVariation(fromContainer) else { return nil }
        return getNextMove(fromContainer, inVariation: parentMove.variations[variation]!)
    }
        
    private func getNextMove(_ fromContainer:MoveContainer?, inVariation:[RowContainer]) -> MoveContainer? {
        guard let fromContainer = fromContainer else { return nil }
        guard let rowIndex = inVariation.firstIndex(where: { $0.white == fromContainer || $0.black == fromContainer}) else { return nil }
        guard fromContainer != inVariation[rowIndex].white else {
            return inVariation[rowIndex].black
        }
        let nextMoveIndex = inVariation.index(after: rowIndex)
        guard inVariation.count > nextMoveIndex else { return  nil}
        return inVariation[nextMoveIndex].white
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
