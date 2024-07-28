import Foundation

public class MoveHistory {
    private var history: [MoveContainer]
    
    public init(history: [MoveContainer] = []) {
        self.history = history
    }

    public func clear() {
        history.removeAll()
    }
    
    public func pop() -> MoveContainer? {
        guard history.isEmpty == false else { return nil }
        history.removeLast()
        return history.last
    }
    
    public func add(_ move:MoveContainer) {
        history.append(move)
    }
    
    public var list:[MoveContainer] {
        history
    }
    
    public func rowNumber() -> Int {
        Int(history.count / 2) + 1
    }
    
    public func createHistory(ofMove:MoveContainer?, inStructure:MoveStructure) {
        history.removeAll()
        var reverseHistory: [MoveContainer] = []
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
    
    private func getReversedVariationHistory(ofMove:MoveContainer, inStructure:MoveStructure) -> [MoveContainer] {
        guard let parrentMove = inStructure.parrent(of: ofMove) else { return [] }
        guard let variationName = parrentMove.getVariation(ofMove) else { return [] }
        guard let variation = parrentMove.variations[variationName] else { return [] }
        guard let rowIndex = variation.firstIndex(where: { $0.white == ofMove || $0.black == ofMove }) else { return [] }
        return getReversedHistory(Array(variation[variation.startIndex...rowIndex]), toMove: ofMove)
    }
    
    private func getReversedHistory(_ rows:[RowContainer], toMove:MoveContainer) -> [MoveContainer] {
        var reverseHistory: [MoveContainer] = []
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
