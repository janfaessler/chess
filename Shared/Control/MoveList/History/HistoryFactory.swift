import Foundation

public class HistoryFactory {
    
    public static func create(ofMove:MoveModel?, inStructure:MoveStructure) -> MoveHistory {
       var history = getHistory(ofMove: ofMove, inStructure: inStructure)
        history.append(ofMove!)
        return MoveHistory(history: history)
    }
    
    private static func getHistory(ofMove:MoveModel?, inStructure:MoveStructure) -> [MoveModel] {
        var reverseHistory: [MoveModel] = []
        guard var move = ofMove else { return [] }
        while  inStructure.parrent(of: move) != nil {
            guard let parrentMove = inStructure.parrent(of: move) else { return [] }
            let reverseVariationHistory = getReversedVariationHistory(ofMove: move, inStructure: inStructure)
            reverseHistory.append(contentsOf: reverseVariationHistory)
            move = parrentMove
        }
       
        let range = inStructure.range(to: move)
        reverseHistory.append(contentsOf: getReversedHistory(range, toMove: move))
        return Array(reverseHistory.reversed())
    }

    
    private static func getReversedVariationHistory(ofMove:MoveModel, inStructure:MoveStructure) -> [MoveModel] {
        guard let parrentMove = inStructure.parrent(of: ofMove) else { return [] }
        guard let variation = parrentMove.getVariation(ofMove) else { return [] }
        return getReversedHistory(variation.range(to: ofMove).all, toMove: ofMove)
    }
    
    private static func getReversedHistory(_ rows:[MovePairModel], toMove:MoveModel) -> [MoveModel] {
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
