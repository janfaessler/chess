import Foundation
import SwiftChessCore

struct MoveData: Codable, Hashable, Sendable {
    let move: String
    let annotation: MoveAnnotation?
    let variations: [[MoveData]]
    let comment: String?
    let highlights: [SquareHighlight]
    let arrows: [BoardArrow]

    init(move: String, annotation: MoveAnnotation? = nil, variations: [[MoveData]], comment: String?, highlights: [SquareHighlight] = [], arrows: [BoardArrow] = []) {
        self.move = move
        self.annotation = annotation
        self.variations = variations
        self.comment = comment
        self.highlights = highlights
        self.arrows = arrows
    }

    static func from(_ pgnMove: PgnMove) -> MoveData {
        MoveData(
            move: pgnMove.move,
            annotation: pgnMove.annotation,
            variations: pgnMove.variations.map { $0.map { MoveData.from($0) } },
            comment: pgnMove.comment,
            highlights: pgnMove.highlights,
            arrows: pgnMove.arrows
        )
    }

    private enum CodingKeys: CodingKey {
        case move, annotation, variations, comment, highlights, arrows
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        move = try container.decode(String.self, forKey: .move)
        annotation = try container.decodeIfPresent(MoveAnnotation.self, forKey: .annotation)
        variations = try container.decode([[MoveData]].self, forKey: .variations)
        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        highlights = try container.decodeIfPresent([SquareHighlight].self, forKey: .highlights) ?? []
        arrows = try container.decodeIfPresent([BoardArrow].self, forKey: .arrows) ?? []
    }
}
