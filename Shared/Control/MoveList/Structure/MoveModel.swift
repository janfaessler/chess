import Foundation

public class MoveModel : Identifiable, Equatable, ObservableObject {
    public let id: UUID = UUID()
    public let move: String
    public let color:PieceColor
    public var note:String?
    
    private var variations: [String:LineModel]
    
    init(move: String, color:PieceColor, variations: [String:LineModel] = [:], note: String? = nil) {
        self.move = move
        self.variations = variations
        self.note = note
        self.color = color
    }
    
    public func getVariationName(_ ofMove:MoveModel) -> String? {
        for variation in variations {
            if variation.value.all.contains(where: { $0.white?.id == ofMove.id || $0.black?.id == ofMove.id }) {
                return variation.key
            }
        }
        return nil
    }

    public func getVariation(_ ofMove:MoveModel) ->  LineModel? {
        guard let name = getVariationName(ofMove) else { return nil }
        return variations[name]
    }
    
    public func getVariation(_ name:String) -> LineModel?{
        guard let variation = variations[name] else { return LineModel() }
        return variation
    }
    
    public func addVariation(_ name:String, variation: LineModel) {
        variations[name] = variation
    }
    
    public func appendVariation(_ container: MoveModel, variation: String) {
        variations[variation]!.last!.black = container
    }
    
    public func appendVariation(_ container: MovePairModel, variation: String) {
        variations[variation]?.add(container)
    }
    
    public func hasVariations() -> Bool {
       variations.count > 0
    }
    
    public func getVariations() -> [String] {
        variations.keys.map({ $0 })
    }
    
    public static func == (lhs: MoveModel, rhs: MoveModel) -> Bool {
        lhs.id == rhs.id
    }
}
