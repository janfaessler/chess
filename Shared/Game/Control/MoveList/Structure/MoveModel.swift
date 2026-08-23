import Foundation
import Observation
import SwiftChessCore

@Observable
class MoveModel : Identifiable, Equatable {
    let id: UUID = UUID()
    let move: String
    let color: PieceColor
    let resultingPosition: Position?
    var note: String?
    var annotation: MoveAnnotation?
    var highlights: [SquareHighlight]
    var arrows: [BoardArrow]

    var variationManager = VariationManager()

    init(
        move: String,
        color: PieceColor,
        note: String? = nil,
        annotation: MoveAnnotation? = nil,
        highlights: [SquareHighlight] = [],
        arrows: [BoardArrow] = [],
        resultingPosition: Position? = nil
    ) {
        self.move = move
        self.note = note
        self.annotation = annotation
        self.highlights = highlights
        self.arrows = arrows
        self.color = color
        self.resultingPosition = resultingPosition
    }

    func getVariationName(_ ofMove: MoveModel) -> String? {
        variationManager.variationName(for: ofMove)
    }

    func getVariation(_ ofMove: MoveModel) -> LineModel? {
        variationManager.variation(for: ofMove)
    }

    func getVariation(_ name: String) -> LineModel? {
        variationManager.variation(named: name)
    }

    func addVariation(_ name: String, variation: LineModel) {
        variationManager.add(name: name, line: variation)
    }

    static func displayName(forVariation key: String) -> String {
        VariationManager.displayName(forKey: key)
    }

    func appendVariation(_ container: MoveModel, variation: String) {
        variationManager.appendMove(container, toVariationNamed: variation)
    }

    func appendVariation(_ container: MovePairModel, variation: String) {
        variationManager.appendPair(container, toVariationNamed: variation)
    }

    func hasVariations() -> Bool {
        variationManager.hasVariations
    }

    func getVariations() -> [String] {
        variationManager.keys
    }

    func removeVariation(_ name: String) {
        variationManager.remove(named: name)
    }

    static func == (lhs: MoveModel, rhs: MoveModel) -> Bool {
        lhs.id == rhs.id
    }
}
