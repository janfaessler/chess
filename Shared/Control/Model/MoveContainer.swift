import Foundation

struct MoveContainer : Identifiable {
    let id: UUID = UUID()
    let move: Move
    let variations: [MoveContainer]
    let note:String?
    
    init(move: Move, variations: [MoveContainer] = [], note: String? = nil) {
        self.move = move
        self.variations = variations
        self.note = note
    }
}
