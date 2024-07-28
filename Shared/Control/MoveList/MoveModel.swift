import Foundation

public class MoveModel : Identifiable, Equatable, ObservableObject {
    public let id: UUID = UUID()
    public let move: String
    public let color:PieceColor
    @Published public var variations: [String:[MovePairModel]]
    @Published public var note:String?
    
    init(move: String, color:PieceColor, variations: [String:[MovePairModel]] = [:], note: String? = nil) {
        self.move = move
        self.variations = variations
        self.note = note
        self.color = color
    }

    public func getVariation(_ ofMove:MoveModel) -> String? {
        for variation in variations {
            if variation.value.contains(where: { $0.white?.id == ofMove.id || $0.black?.id == ofMove.id }) {
                return variation.key
            }
        }
        return nil
    }
    
    public func hasVariations() -> Bool {
       variations.count > 0
    }
    
    public func getVariations() -> [String] {
        variations.keys.map({ $0 })
    }
    
    public func getVariation(_ name:String) -> [MovePairModel] {
        guard let variation = variations[name] else { return [] }
        return variation
    }
    
    public static func == (lhs: MoveModel, rhs: MoveModel) -> Bool {
        lhs.id == rhs.id
    }
}
