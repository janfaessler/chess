import Foundation

public class MoveStructure {
    private var rows:LineModel
    private var parrentMoves:[UUID:MoveModel]
    
    init(line: LineModel? = nil, parrentMoves: [UUID : MoveModel] = [:]) {
        self.rows = line ?? LineModel()
        self.parrentMoves = parrentMoves
    }
    
    public var last:MoveModel? {
        rows.last!.hasBlackMoved() ? rows.last!.black : rows.last!.white
    }
    
    public var count:Int {
        return rows.count
    }
    
    public var list:[MovePairModel] {
        rows.all
    }
    
    public func range(to:MoveModel) -> [MovePairModel] {
        rows.range(to: to).all
    }
    
    public func get(after:MoveModel?) -> MoveModel? {
        guard let fromContainer = after else {
            return rows.first?.white
        }
        if !parrentMoves.contains(where: { $0.key == fromContainer.id}) {
            guard let index = rows.index(of:fromContainer) else { return nil }
            guard fromContainer == rows.getMove(index, color: .black) else {
                return rows.getMove(index, color: .black) 
            }
            return rows.getMove(index + 1, color: .white)
        }
        guard let parrentMove = parrentMoves[fromContainer.id] else { return nil }
        guard let variation = parrentMove.getVariation(fromContainer) else { return nil }
        return variation.getMove(after: fromContainer)
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
            return rows.getPair(of: move)?.moveNumber ?? 1
        }
        guard let variation = parrent.getVariation(move) else { return 1 }
        return variation.getPair(of: move)?.moveNumber ?? 1
    }
    
    private func addTopLevelMove(_ container: MoveModel) {
        guard rows.count > 0 else {
            rows.add(MovePairModel.create(container, moveNumber: 1))
            return
        }
        if rows.last?.hasBlackMoved() == true {
            rows.add(MovePairModel.create(container, moveNumber: rows.count + 1))
        } else {
            rows.last?.black = container
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
              let rowContainer = variation.getPair(of: lastMove)
        else { return true }
        
        
        if lastMove == rowContainer.white {
            return rowContainer.hasBlackMoved()
        }
        
        if rowContainer == variation.last {
            return false
        }
        
        let nextRow = variation.getMove(after: rowContainer.black)
        return nextRow?.move != currentMove?.move
    }
    
    private func addNewVariation( _ container: MoveModel, to: MoveModel) {
        let moveNumber = number(of:to)
        let rowContainer = MovePairModel.create(container, moveNumber: moveNumber)
        
        to.addVariation(container.move, variation:LineModel([rowContainer]))
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
}
