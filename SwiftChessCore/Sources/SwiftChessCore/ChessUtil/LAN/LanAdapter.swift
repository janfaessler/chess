import Foundation

public struct LanAdapter: MoveNotationPort {
    public init() {}

    public func parse(_ notation: String, in position: Position) -> Move? {
        LanParser.parse(lan: notation, position: position)
    }

    public func generate(_ move: Move, in position: Position) -> String {
        move.info
    }
}
