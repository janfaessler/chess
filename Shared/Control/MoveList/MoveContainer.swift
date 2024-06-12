import Foundation

public class MoveContainer : Identifiable, Equatable {
    public let id: UUID = UUID()
    public let move: Move
    public var variations: [String:[MoveContainer]]
    public var note:String?
    
    init(move: Move, variations: [String:[MoveContainer]] = [:], note: String? = nil) {
        self.move = move
        self.variations = variations
        self.note = note
    }

    public func getVariation(_ ofMove:MoveContainer) -> String? {
        for variation in variations {
            if variation.value.contains(where: { $0.id == ofMove.id}) {
                return variation.key
            }
        }
        return nil
    }
    
    public static func == (lhs: MoveContainer, rhs: MoveContainer) -> Bool {
        lhs.id == rhs.id
    }
}
