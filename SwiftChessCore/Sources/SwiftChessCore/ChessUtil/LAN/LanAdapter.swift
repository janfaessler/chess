import Foundation

public struct LanAdapter: MoveNotationPort {
    public init() {}

    public func parse(_ notation: String, in position: Position) -> Move? {
        LanParser.parse(lan: notation, position: position)
    }

    public func generate(_ move: Move, in position: Position) -> String {
        let lan = move.startingSquare.info + move.destination.info
        guard move.type == .promotion else { return lan }
        return lan + String(move.promoteTo.pieceType.fenChar(for: .black))
    }
}
