import Foundation

public struct PgnMove: Sendable {
    public let id = UUID()
    public let move: String
    public let annotation: MoveAnnotation?
    public let variations: [[PgnMove]]
    public let comment: String?
    public let highlights: [SquareHighlight]
    public let arrows: [BoardArrow]

    public init(
        move: String,
        annotation: MoveAnnotation? = nil,
        variations: [[PgnMove]],
        comment: String?,
        highlights: [SquareHighlight] = [],
        arrows: [BoardArrow] = []
    ) {
        self.move = move
        self.annotation = annotation
        self.variations = variations
        self.comment = comment
        self.highlights = highlights
        self.arrows = arrows
    }
}
