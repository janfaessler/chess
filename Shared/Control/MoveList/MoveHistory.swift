import Foundation

public class MoveHistory {
    private var history: [MoveModel]
    
    public init(history: [MoveModel] = []) {
        self.history = history
    }

    public func clear() {
        history.removeAll()
    }
    
    public func pop() -> MoveModel? {
        guard history.isEmpty == false else { return nil }
        history.removeLast()
        return history.last
    }
    
    public func add(_ move:MoveModel) {
        history.append(move)
    }
    
    public var list:[MoveModel] {
        history
    }
    
    public func rowNumber() -> Int {
        Int(history.count / 2) + 1
    }
    
    public func createHistory(ofMove:MoveModel?, inStructure:MoveStructure) {
        history.removeAll()
        var reverseHistory: [MoveModel] = []
        guard var move = ofMove else { return }
        while  inStructure.parrent(of: move) != nil {
            guard let parrentMove = inStructure.parrent(of: move) else { return }
            let reverseVariationHistory = getReversedVariationHistory(ofMove: move, inStructure: inStructure)
            reverseHistory.append(contentsOf: reverseVariationHistory)
            move = parrentMove
        }
       
        let range = inStructure.range(to: move)
        reverseHistory.append(contentsOf: getReversedHistory(range, toMove: move))
        history.append(contentsOf: reverseHistory.reversed())
        history.append(ofMove!)
    }
    
    private func getReversedVariationHistory(ofMove:MoveModel, inStructure:MoveStructure) -> [MoveModel] {
        guard let parrentMove = inStructure.parrent(of: ofMove) else { return [] }
        guard let variationName = parrentMove.getVariation(ofMove) else { return [] }
        guard let variation = parrentMove.variations[variationName] else { return [] }
        guard let rowIndex = variation.firstIndex(where: { $0.white == ofMove || $0.black == ofMove }) else { return [] }
        return getReversedHistory(Array(variation[variation.startIndex...rowIndex]), toMove: ofMove)
    }
    
    private func getReversedHistory(_ rows:[MovePairModel], toMove:MoveModel) -> [MoveModel] {
        var reverseHistory: [MoveModel] = []
        for row in rows.reversed() {
            if row.hasBlackMoved() && row.white != toMove && row.black != toMove {
                reverseHistory.append(row.black!)
            }
            if row.hasWhiteMoved() && row.white != toMove {
                reverseHistory.append(row.white!)
            }
        }
        return reverseHistory
    }
}
