import Foundation
import os

public class MoveListModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MoveListModel")
    
    typealias PositionChangeNotification = (Position) -> ()
    private var positionChangeNotification:[PositionChangeNotification] = []
    
    private var parrentMoves:[UUID:MoveContainer] = [:]
    
    private let moves = MoveStack()
    
    @Published public var rows:[RowContainer] = []
    @Published public var currentMove:MoveContainer?
    
    public init() {}
    
    var moveCount:Int {
        let moveCount = Float(rows.count / 2)
        let roundedCount = moveCount.rounded(.up)
        let result = Int(roundedCount) + rows.count % 2
        return result
    }
    
    public func start() {
        moves.clear()
        currentMove = nil
        updatePosition()
    }
    
    public func back() {
        currentMove = moves.pop()
        updatePosition()
    }
    
    public func forward() {
        guard let nextMove = getNextMove(currentMove) else { return }
        self.currentMove = nextMove
        moves.add(nextMove)
        updatePosition()
    }
    
    public func end() {
        currentMove = rows.last!.hasBlackMoved() ? rows.last!.black : rows.last!.white
        moves.createHistory(ofMove: currentMove, inStructure: rows, parrentMoves: parrentMoves)
        updatePosition()
    }
    
    public func goToMove(_ move:MoveContainer) {
        currentMove = move
        moves.createHistory(ofMove: currentMove, inStructure: rows, parrentMoves: parrentMoves)
        updatePosition()
    }
    
    public func movePlayed(_ move:String) {
        let color = currentMove?.color == .white ? PieceColor.black : PieceColor.white
        let container = MoveContainer(move: move, color: color)
        let blackHasLastTopLevelMove = rows.last?.black != nil
        
        let nextMove = getNextMove(currentMove)
        if move == nextMove?.move {
            replayMove(nextMove!)
            return
        }

        if (blackHasLastTopLevelMove && currentMove == rows.last?.black) || (!blackHasLastTopLevelMove && rows.last?.white == currentMove) {
            addTopLevelMove(container)
        } else {
            addVariationMove(container)
        }
    }
    
    public func getPosition() -> Position? {
        guard currentMove != nil else { return PositionFactory.startingPosition() }
        let notations = getMoveNotations()
        return PositionFactory.loadPosition(notations)
    }
    
    public func isCurrentMove(_ container:MoveContainer?) -> Bool {
        currentMove == container
    }
    
    public func atStartPosition() -> Bool {
        currentMove == nil
    }
    
    public func reset() {
        currentMove = nil
        rows.removeAll()
        moves.clear()
    }
    
    public func updateMoveList(_ input:[RowContainer]) {
        reset()
        rows = input
        createVariationCache()
    }
    
    public func getMoveNotations() -> [String] {
        moves.list().map({ $0.move })
    }
    
    func addPositionChangeListener(_ listener:@escaping PositionChangeNotification) {
        positionChangeNotification += [listener]
    }
    
    private func replayMove(_ nextMove: MoveContainer) {
        currentMove = nextMove
        moves.add(nextMove)
    }
    
    private func addTopLevelMove(_ container: MoveContainer) {
        guard rows.count > 0 else {
            rows += [RowContainer(moveNumber: 1, white: container)]
            currentMove = container
            moves.add(container)
            return
        }
        if rows[rows.index(before: rows.endIndex)].hasBlackMoved() == true {
            rows += [RowContainer(moveNumber: rows.count + 1, white: container)]
        } else {
            rows[rows.index(before: rows.endIndex)].black = container
        }
        currentMove = container
        moves.add(container)
    }
    
    private func addVariationMove(_ container:MoveContainer) {
        guard let nextMove = getNextMove(currentMove) ?? currentMove else { return }
        let parentMove = parrentMoves[nextMove.id]
        let moveInVariation = parentMove?.getVariation(nextMove)
        if  shouldCreateNewVariation(container) {
            addNewVariation(container, to: nextMove)
        } else {
            appendVariation(container, to: parentMove!, variation: moveInVariation!, lastMove: nextMove)
        }
        
        self.currentMove = container
        moves.add(container)
    }
    
    private func shouldCreateNewVariation(_ container:MoveContainer) -> Bool {
        guard let lastMove = currentMove,
              let parentMove = parrentMoves[lastMove.id],
              let lastMoveVariation = parentMove.getVariation(lastMove),
              let variation = parentMove.variations[lastMoveVariation],
              container.color != lastMove.color,
              let rowIndexInVariation = variation.firstIndex(where: { $0.white == lastMove || $0.black == lastMove })
        else { return true }
        
        
        let rowContainer = variation[rowIndexInVariation]
        
        if lastMove == rowContainer.white {
            return rowContainer.hasBlackMoved()
        }
        
        if rowIndexInVariation + 1 == variation.endIndex {
            return false
        }
        
        let nextRowIndexInVariation = variation.index(after: rowIndexInVariation)
        let nextRow = variation[nextRowIndexInVariation]
        return nextRow.white?.move != currentMove?.move
    }
    
    private func createRowContainer(_ container: MoveContainer, moveNumber:Int = 1) -> RowContainer {
        var rowContainer:RowContainer
        if container.color == .white {
            rowContainer = RowContainer(moveNumber: moveNumber, white: container)
        } else {
            rowContainer = RowContainer(moveNumber: moveNumber, black: container)
        }
        return rowContainer
    }
    
    private func appendVariation(_ container: MoveContainer, to: MoveContainer, variation: String, lastMove: MoveContainer) {
        let rowNumber = moves.rowNumber()
        if container.color == .white {
            let rowContainer = createRowContainer(container, moveNumber: rowNumber)
            to.variations[variation]?.append(rowContainer)
        } else {
            to.variations[variation]!.last!.black = container
        }
        parrentMoves[container.id] = to
    }
    
    private func addNewVariation( _ container: MoveContainer, to: MoveContainer) {
        let moveNumber = moves.rowNumber()
        let rowContainer = createRowContainer(container, moveNumber: moveNumber)
        
        to.variations[container.move] = [rowContainer]
        parrentMoves[container.id] = to
    }
    
    private func getNextMove(_ fromContainer:MoveContainer?) -> MoveContainer? {
        guard let fromContainer = fromContainer else {
            return rows.first?.white
        }
        if !parrentMoves.contains(where: { $0.key == fromContainer.id}) {
            guard let index = rows.firstIndex(where: { $0.white?.id == fromContainer.id || $0.black?.id == fromContainer.id }) else { return nil }
    
            guard fromContainer == rows[index].black else {
                return rows[index].black
            }

            let nextIndex = rows.index(after: index)
            if nextIndex == rows.count { return nil }
            return rows[nextIndex].white
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
    
    private func createVariationCache() {
        for row in rows {
            if row.hasWhiteVariations() {
                createCacheForVariations(row.white!)
            }
            if row.hasBlackVariations() {
                createCacheForVariations(row.black!)
            }
        }
    }
    
    private func createCacheForVariations(_ move: MoveContainer) {
        let variations = move.variations
        for name in variations.keys {
            guard let variation = variations[name] else { continue }
            for row in variation {
                createCacheForVariations(row, to: move)
            }
        }
    }
    
    private func createCacheForVariations(_ row: RowContainer, to:MoveContainer) {
        if row.hasWhiteMoved() {
            guard let move = row.white else { return }
            parrentMoves[move.id] = to
            createCacheForVariations(move)
        }
        if row.hasBlackMoved() {
            guard let move = row.black else { return }
            parrentMoves[move.id] = to
            createCacheForVariations(move)
        }
    }
}
