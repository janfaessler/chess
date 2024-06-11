import Foundation

class MoveContainer : Identifiable, Equatable {
    let id: UUID = UUID()
    let move: Move
    var variations: [String:[MoveContainer]]
    var note:String?
    
    init(move: Move, variations: [String:[MoveContainer]] = [:], note: String? = nil) {
        self.move = move
        self.variations = variations
        self.note = note
    }

    func getVariation(_ ofMove:MoveContainer) -> String? {
        for variation in variations {
            if variation.value.contains(where: { $0.id == ofMove.id}) {
                return variation.key
            }
        }
        return nil
    }
    
    static func == (lhs: MoveContainer, rhs: MoveContainer) -> Bool {
        lhs.id == rhs.id
    }
}
