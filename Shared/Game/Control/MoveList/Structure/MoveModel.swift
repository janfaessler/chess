import Foundation
import Observation

@Observable
class MoveModel : Identifiable, Equatable {
    let id: UUID = UUID()
    let move: String
    let color: PieceColor
    var note: String?

    private var variations: [String: LineModel]

    init(move: String, color: PieceColor, variations: [String: LineModel] = [:], note: String? = nil) {
        self.move = move
        self.variations = variations
        self.note = note
        self.color = color
    }

    func getVariationName(_ ofMove: MoveModel) -> String? {
        for variation in variations {
            if variation.value.all.contains(where: { $0.white?.id == ofMove.id || $0.black?.id == ofMove.id }) {
                return variation.key
            }
        }
        return nil
    }

    func getVariation(_ ofMove: MoveModel) -> LineModel? {
        guard let name = getVariationName(ofMove) else { return nil }
        return variations[name]
    }

    func getVariation(_ name: String) -> LineModel? {
        guard let variation = variations[name] else { return LineModel() }
        return variation
    }

    func addVariation(_ name: String, variation: LineModel) {
        variations[name] = variation
    }

    func appendVariation(_ container: MoveModel, variation: String) {
        variations[variation]?.last?.black = container
    }

    func appendVariation(_ container: MovePairModel, variation: String) {
        variations[variation]?.add(container)
    }

    func hasVariations() -> Bool {
        variations.count > 0
    }

    func getVariations() -> [String] {
        variations.keys.map({ $0 })
    }

    static func == (lhs: MoveModel, rhs: MoveModel) -> Bool {
        lhs.id == rhs.id
    }
}
