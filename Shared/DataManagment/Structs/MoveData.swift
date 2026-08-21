import Foundation
import SwiftChessCore

struct MoveData: Codable, Hashable {
    let move: String
    let variations: [[MoveData]]
    let comment: String?

    static func from(_ pgnMove: PgnMove) -> MoveData {
        MoveData(
            move: pgnMove.move,
            variations: pgnMove.variations.map { $0.map { MoveData.from($0) } },
            comment: pgnMove.comment
        )
    }
}
