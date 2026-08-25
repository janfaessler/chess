import Foundation

public protocol MoveNotationPort {
    func parse(_ notation: String, in position: Position) -> Move?
    func generate(_ move: Move, in position: Position) -> String
}
