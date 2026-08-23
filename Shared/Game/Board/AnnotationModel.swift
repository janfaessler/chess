import SwiftUI
import SwiftChessCore

@Observable
class AnnotationModel {
    private static let colorCycle: [AnnotationColor] = [.green, .yellow, .red, .blue]

    private(set) var pgnHighlights: [SquareHighlight] = []
    private(set) var pgnArrows: [BoardArrow] = []
    private(set) var userHighlights: [SquareHighlight] = []
    private(set) var userArrows: [BoardArrow] = []

    var allHighlights: [SquareHighlight] { pgnHighlights + userHighlights }
    var allArrows: [BoardArrow] { pgnArrows + userArrows }

    func updatePgn(highlights: [SquareHighlight], arrows: [BoardArrow]) {
        pgnHighlights = highlights
        pgnArrows = arrows
    }

    func toggleHighlight(square: String) {
        if let idx = userHighlights.firstIndex(where: { $0.square == square }) {
            let currentColor = userHighlights[idx].color
            let cycleIdx = Self.colorCycle.firstIndex(of: currentColor)
            if let cycleIdx, cycleIdx + 1 < Self.colorCycle.count {
                userHighlights[idx] = SquareHighlight(color: Self.colorCycle[cycleIdx + 1], square: square)
            } else {
                userHighlights.remove(at: idx)
            }
        } else {
            userHighlights.append(SquareHighlight(color: .green, square: square))
        }
    }

    func toggleArrow(from: String, to: String, color: AnnotationColor) {
        if let idx = userArrows.firstIndex(where: { $0.from == from && $0.to == to }) {
            if userArrows[idx].color == color {
                userArrows.remove(at: idx)
            } else {
                userArrows[idx] = BoardArrow(color: color, from: from, to: to)
            }
        } else {
            userArrows.append(BoardArrow(color: color, from: from, to: to))
        }
    }

    func clearUserAnnotations() {
        userHighlights.removeAll()
        userArrows.removeAll()
    }
}
