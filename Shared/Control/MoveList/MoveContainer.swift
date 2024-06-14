import Foundation

public class MoveContainer : Identifiable, Equatable, ObservableObject {
    public let id: UUID = UUID()
    public let move: Move
    @Published public var variations: [String:[RowContainer]]
    @Published public var note:String?
    
    init(move: Move, variations: [String:[RowContainer]] = [:], note: String? = nil) {
        self.move = move
        self.variations = variations
        self.note = note
    }

    public func getVariation(_ ofMove:MoveContainer) -> String? {
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
    
    public static func == (lhs: MoveContainer, rhs: MoveContainer) -> Bool {
        lhs.id == rhs.id
    }
}
