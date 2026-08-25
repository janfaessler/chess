import Foundation

public struct SanAdapter: MoveNotationPort {
    public init() {}

    public func parse(_ notation: String, in position: Position) -> Move? {
        MoveFactory.create(notation, position: position)
    }

    public func generate(_ move: Move, in position: Position) -> String {
        NotationFactory.generate(move, position: position)
    }
}
