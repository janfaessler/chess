import Foundation

public protocol PositionNotationPort {
    func parse(_ notation: String) throws -> Position
    func serialize(_ position: Position) -> String
}
