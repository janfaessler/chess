import Foundation

public struct FenAdapter: PositionNotationPort {
    public init() {}

    public func parse(_ notation: String) throws -> Position {
        try FenParser.parse(notation)
    }

    public func serialize(_ position: Position) -> String {
        FenBuilder.create(position)
    }
}
