import Foundation

class MoveStructure: @unchecked Sendable {
    private var line:LineModel
    private var parentMoves:[UUID:MoveModel]
    
    init(line: LineModel? = nil, parentMoves: [UUID : MoveModel] = [:]) {
        self.line = line ?? LineModel()
        self.parentMoves = parentMoves
    }
    
    var last: MoveModel? {
        guard let pair = line.last else { return nil }
        return pair.hasBlackMoved() ? pair.black : pair.white
    }
    
    var count:Int {
        return line.count
    }
    
    var lineModel: LineModel {
        line
    }

    var list:[MovePairModel] {
        line.all
    }
    
    func range(to:MoveModel) -> [MovePairModel] {
        line.range(to: to).all
    }
    
    func get(after:MoveModel?) -> MoveModel? {
        guard let fromContainer = after else {
            return line.first
        }
        if !parentMoves.contains(where: { $0.key == fromContainer.id}) {
            guard let index = line.index(of:fromContainer) else { return nil }
            guard fromContainer == line.getMove(index, color: .black) else {
                return line.getMove(index, color: .black) 
            }
            return line.getMove(index + 1, color: .white)
        }
        guard let parentMove = parentMoves[fromContainer.id] else { return nil }
        guard let variation = parentMove.getVariation(fromContainer) else { return nil }
        return variation.getMove(after: fromContainer)
    }
    
    func add(_ move:MoveModel, currentMove:MoveModel?) {
        if (shouldAddOnTopLevel(move, currentMove: currentMove)) {
            addTopLevelMove(move)
        } else {
            addVariationMove(move, currentMove: currentMove)
        }
    }

    func parent(of:MoveModel) -> MoveModel? {
        parentMoves[of.id]
    }
    
    func number(of:MoveModel) -> Int {
        let move = of
        guard let parent = parent(of: move) else {
            return line.getPair(of: move)?.moveNumber ?? 1
        }
        guard let variation = parent.getVariation(move) else { return 1 }
        return variation.getPair(of: move)?.moveNumber ?? 1
    }
    
    func move(_ currentMove:MoveModel?, isChildOf:MoveModel) -> Bool {
        guard let currentMove = currentMove else { return false }
        guard currentMove != isChildOf else { return true }
        
        var parentMove = parent(of: currentMove)
        while let current = parentMove {
            if current.id == isChildOf.id { return true }
            parentMove = parent(of: current)
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
              let parentMove = parentMoves[lastMove.id],
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
        parentMoves[container.id] = to
    }
    
    private func appendVariation(_ container: MoveModel, nextMove: MoveModel) {
        guard let to = parentMoves[nextMove.id] else { return }
        guard let variationName = to.getVariationName(nextMove) else { return }
        if container.color == .white {
            let rowContainer = MovePairModel.create(container, moveNumber: number(of: nextMove) + 1)
            to.appendVariation(rowContainer, variation: variationName)
        } else {
            to.appendVariation(container, variation: variationName)
        }
        parentMoves[container.id] = to
    }

    func deleteFrom(_ move: MoveModel) {
        let removed: [MoveModel]
        if line.index(of: move) != nil {
            removed = line.truncate(from: move)
        } else if let parent = parentMoves[move.id],
                  let variationName = parent.getVariationName(move),
                  let variation = parent.getVariation(variationName) {
            removed = variation.truncate(from: move)
        } else {
            return
        }
        cleanupParentMoves(for: removed)
    }

    func deleteVariation(name: String, from: MoveModel) {
        guard let variation = from.getVariation(name) else { return }
        var removed: [MoveModel] = []
        for pair in variation.all {
            if let w = pair.white { removed.append(w) }
            if let b = pair.black { removed.append(b) }
        }
        cleanupParentMoves(for: removed)
        from.removeVariation(name)
    }

    private func cleanupParentMoves(for moves: [MoveModel]) {
        for move in moves {
            parentMoves.removeValue(forKey: move.id)
            for variationName in move.getVariations() {
                if let variation = move.getVariation(variationName) {
                    var nested: [MoveModel] = []
                    for pair in variation.all {
                        if let w = pair.white { nested.append(w) }
                        if let b = pair.black { nested.append(b) }
                    }
                    cleanupParentMoves(for: nested)
                }
            }
        }
    }
}
