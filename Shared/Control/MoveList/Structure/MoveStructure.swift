import Foundation

public class MoveStructure {
    private var line:LineModel
    private var parrentMoves:[UUID:MoveModel]
    
    init(line: LineModel? = nil, parrentMoves: [UUID : MoveModel] = [:]) {
        self.line = line ?? LineModel()
        self.parrentMoves = parrentMoves
    }
    
    public var last:MoveModel? {
        line.last!.hasBlackMoved() ? line.last!.black : line.last!.white
    }
    
    public var count:Int {
        return line.count
    }
    
    public var list:[MovePairModel] {
        line.all
    }
    
    public func range(to:MoveModel) -> [MovePairModel] {
        line.range(to: to).all
    }
    
    public func get(after:MoveModel?) -> MoveModel? {
        guard let fromContainer = after else {
            return line.first
        }
        if !parrentMoves.contains(where: { $0.key == fromContainer.id}) {
            guard let index = line.index(of:fromContainer) else { return nil }
            guard fromContainer == line.getMove(index, color: .black) else {
                return line.getMove(index, color: .black) 
            }
            return line.getMove(index + 1, color: .white)
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
            return line.getPair(of: move)?.moveNumber ?? 1
        }
        guard let variation = parrent.getVariation(move) else { return 1 }
        return variation.getPair(of: move)?.moveNumber ?? 1
    }
    
    public func move(_ currentMove:MoveModel?, isChildOf:MoveModel) -> Bool {
        guard let currentMove = currentMove else { return false }
        guard currentMove != isChildOf else { return true }
        
        var parrentMove = parrent(of: currentMove)
        while parrentMove != nil {
            if parrentMove?.id == isChildOf.id { return true }
            parrentMove = parrent(of:parrentMove!)
        }
        return false
    }
    
    private func addTopLevelMove(_ container: MoveModel) {
        guard line.count > 0 else {
            line.add(MovePairModel.create(container, moveNumber: 1))
            return
        }
        if line.last?.hasBlackMoved() == true {
            line.add(MovePairModel.create(container, moveNumber: line.count + 1))
        } else {
            line.last?.black = container
        }
    }
    
    private func shouldAddOnTopLevel(_ move:MoveModel, currentMove: MoveModel?) -> Bool {
        let blackHasLastTopLevelMove = line.last?.black != nil
        return (blackHasLastTopLevelMove && currentMove == line.last?.black) || (!blackHasLastTopLevelMove && line.last?.white == currentMove)
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
