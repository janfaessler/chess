import Foundation

public class MoveStructure {
    private var rows:[MovePairModel]
    private var parrentMoves:[UUID:MoveModel]
    
    init(rows: [MovePairModel] = [], parrentMoves: [UUID : MoveModel] = [:]) {
        self.rows = rows
        self.parrentMoves = parrentMoves
    }
    
    public var last:MoveModel? {
        rows.last!.hasBlackMoved() ? rows.last!.black : rows.last!.white
    }
    
    public var count:Int {
        let moveCount = Float(rows.count / 2)
        let roundedCount = moveCount.rounded(.up)
        let result = Int(roundedCount) + rows.count % 2
        return result
    }
    
    public var list:[MovePairModel] {
        rows
    }
    
    public func get(after:MoveModel?) -> MoveModel? {
        guard let fromContainer = after else {
            return rows.first?.white
        }
        if !parrentMoves.contains(where: { $0.key == fromContainer.id}) {
            guard let index = getIndex(fromContainer, inRow: rows) else { return nil }
    
            guard fromContainer == rows[index].black else {
                return rows[index].black
            }

            let nextIndex = rows.index(after: index)
            if nextIndex == rows.count { return nil }
            return rows[nextIndex].white
        }
        guard let parentMove = parrentMoves[fromContainer.id] else { return nil }
        guard let variation = parentMove.getVariation(fromContainer) else { return nil }
        return getNextMove(fromContainer, inVariation: variation)
    }
    
    public func range(to:MoveModel) -> [MovePairModel] {
        guard let index = getIndex(to, inRow: rows) else { return [] }
        return Array(rows[rows.startIndex...index])
    }
    
    public func add(_ move:MoveModel, currentMove:MoveModel?) {
        if (shouldAddOnTopLevel(move, currentMove: currentMove)) {
            addTopLevelMove(move)
        } else {
            addVariationMove(move, currentMove: currentMove)
        }
    }

    public func parrent(of:MoveModel) -> MoveModel? {
        parrentMoves[of.id]
    }
    
    public func number(of:MoveModel) -> Int {
        let move = of
        guard let parrent = parrent(of: move) else {
            return getPairOf(move, inRow: rows)?.moveNumber ?? 1
        }
        guard let variation = parrent.getVariation(move) else { return 1 }
        return getPairOf(move, inRow: variation)?.moveNumber ?? 1
    }
    
    private func getNextMove(_ fromContainer:MoveModel?, inVariation:[MovePairModel]) -> MoveModel? {
        guard let fromContainer = fromContainer else { return nil }
        guard let rowIndex = getIndex(fromContainer, inRow: inVariation) else { return nil }
        guard fromContainer != inVariation[rowIndex].white else {
            return inVariation[rowIndex].black
        }
        let nextMoveIndex = inVariation.index(after: rowIndex)
        guard inVariation.count > nextMoveIndex else { return  nil}
        return inVariation[nextMoveIndex].white
    }

    private func addTopLevelMove(_ container: MoveModel) {
        guard rows.count > 0 else {
            rows += [MovePairModel.create(container, moveNumber: 1)]
            return
        }
        if rows[rows.index(before: rows.endIndex)].hasBlackMoved() == true {
            rows += [MovePairModel.create(container, moveNumber: rows.count + 1)]
        } else {
            rows[rows.index(before: rows.endIndex)].black = container
        }
    }
    
    private func shouldAddOnTopLevel(_ move:MoveModel, currentMove: MoveModel?) -> Bool {
        let blackHasLastTopLevelMove = rows.last?.black != nil
        return (blackHasLastTopLevelMove && currentMove == rows.last?.black) || (!blackHasLastTopLevelMove && rows.last?.white == currentMove)
    }
    
    private func addVariationMove(_ container:MoveModel, currentMove:MoveModel?) {
        guard let nextMove = get(after: currentMove) ?? currentMove else { return }
        if shouldCreateNewVariation(container, currentMove: currentMove) {
            addNewVariation(container, to: nextMove)
        } else {
            appendVariation(container, nextMove: nextMove)
        }
    }
    
    private func shouldCreateNewVariation(_ container:MoveModel, currentMove:MoveModel?) -> Bool {
        guard let lastMove = currentMove,
              let parentMove = parrentMoves[lastMove.id],
              let variation = parentMove.getVariation(lastMove),
              container.color != lastMove.color,
              let rowIndexInVariation = getIndex(lastMove, inRow: variation)
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
    
    private func addNewVariation( _ container: MoveModel, to: MoveModel) {
        let moveNumber = number(of:to)
        let rowContainer = MovePairModel.create(container, moveNumber: moveNumber)
        
        to.addVariation(container.move, variation: [rowContainer])
        parrentMoves[container.id] = to
    }
    
    private func appendVariation(_ container: MoveModel, nextMove: MoveModel) {
        guard let to = parrentMoves[nextMove.id] else { return }
        guard let variationName = to.getVariationName(nextMove) else { return }
        if container.color == .white {
            let rowContainer = MovePairModel.create(container, moveNumber: number(of: nextMove) + 1)
            to.appendVariation(rowContainer, variation: variationName)
        } else {
            to.appendVariation(container, variation: variationName)
        }
        parrentMoves[container.id] = to
    }
    
    private func getPairOf(_ move:MoveModel, inRow:[MovePairModel]) -> MovePairModel? {
        guard let index = getIndex(move, inRow: inRow) else { return nil }
        guard inRow.count > index else { return nil }
        return inRow[index]
    }
    
    private func getIndex(_ move:MoveModel, inRow:[MovePairModel]) -> Int? {
        guard let index = inRow.firstIndex(where: { $0.white?.id == move.id || $0.black?.id == move.id }) else { return nil }
        return index
    }
}
