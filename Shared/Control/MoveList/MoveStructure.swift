import Foundation

public class MoveStructure {
    private var rows:[RowContainer] = []
    private var parrentMoves:[UUID:MoveContainer] = [:]
    
    public var last:MoveContainer? {
        rows.last!.hasBlackMoved() ? rows.last!.black : rows.last!.white
    }
    
    public var count:Int {
        let moveCount = Float(rows.count / 2)
        let roundedCount = moveCount.rounded(.up)
        let result = Int(roundedCount) + rows.count % 2
        return result
    }
    
    public var list:[RowContainer] {
        rows
    }
    
    public func get(after:MoveContainer?) -> MoveContainer? {
        guard let fromContainer = after else {
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
    
    public func range(to:MoveContainer) -> [RowContainer] {
        guard let index = rows.firstIndex(where: { $0.white == to || $0.black == to }) else { return [] }
        return Array(rows[rows.startIndex...index])
    }
    
    public func add(_ move:MoveContainer, currentMove:MoveContainer?) {
        let blackHasLastTopLevelMove = rows.last?.black != nil

        if (blackHasLastTopLevelMove && currentMove == rows.last?.black) || (!blackHasLastTopLevelMove && rows.last?.white == currentMove) {
            addTopLevelMove(move)
        } else {
            addVariationMove(move, currentMove: currentMove)
        }
    }
    
    public func clear() {
        rows.removeAll()
    }
    
    public func set(_ input:[RowContainer]) {
        rows = input
        createVariationCache()
    }
    
    public func parrent(of:MoveContainer) -> MoveContainer? {
        parrentMoves[of.id]
    }
    
    public func number(of:MoveContainer) -> Int {
        let move = of
        guard let parrent = parrent(of: move) else {
            guard let index = rows.firstIndex(where: { $0.white?.id == move.id || $0.black?.id == move.id }) else { return 1 }
            return rows[index].moveNumber
        }
        guard let variationName = parrent.getVariation(move) else { return 1 }
        let variation = parrent.getVariation(variationName)
        guard let index = variation.firstIndex(where: { $0.white?.id == move.id || $0.black?.id == move.id }) else { return 1 }
        return variation[index].moveNumber
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

    private func addTopLevelMove(_ container: MoveContainer) {
        guard rows.count > 0 else {
            rows += [RowContainer(moveNumber: 1, white: container)]
            return
        }
        if rows[rows.index(before: rows.endIndex)].hasBlackMoved() == true {
            rows += [RowContainer(moveNumber: rows.count + 1, white: container)]
        } else {
            rows[rows.index(before: rows.endIndex)].black = container
        }
    }
    
    private func addVariationMove(_ container:MoveContainer, currentMove:MoveContainer?) {
        guard let nextMove = get(after: currentMove) ?? currentMove else { return }
        let parentMove = parrentMoves[nextMove.id]
        let moveInVariation = parentMove?.getVariation(nextMove)
        if  shouldCreateNewVariation(container, currentMove: currentMove) {
            addNewVariation(container, to: nextMove)
        } else {
            appendVariation(container, to: parentMove!, variation: moveInVariation!, lastMove: nextMove)
        }
    }
    
    private func shouldCreateNewVariation(_ container:MoveContainer, currentMove:MoveContainer?) -> Bool {
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
    
    private func appendVariation(_ container: MoveContainer, to: MoveContainer, variation: String, lastMove: MoveContainer) {
        
        if container.color == .white {
            let moveNumber = number(of: lastMove) + 1
            let rowContainer = createRowContainer(container, moveNumber: moveNumber)
            to.variations[variation]?.append(rowContainer)
        } else {
            to.variations[variation]!.last!.black = container
        }
        parrentMoves[container.id] = to
    }
    
    private func addNewVariation( _ container: MoveContainer, to: MoveContainer) {
        let moveNumber = number(of:to)
        let rowContainer = createRowContainer(container, moveNumber: moveNumber)
        
        to.variations[container.move] = [rowContainer]
        parrentMoves[container.id] = to
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
    
    private func createRowContainer(_ container: MoveContainer, moveNumber:Int = 1) -> RowContainer {
        var rowContainer:RowContainer
        if container.color == .white {
            rowContainer = RowContainer(moveNumber: moveNumber, white: container)
        } else {
            rowContainer = RowContainer(moveNumber: moveNumber, black: container)
        }
        return rowContainer
    }

}
