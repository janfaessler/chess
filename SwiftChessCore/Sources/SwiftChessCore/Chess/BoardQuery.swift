import Foundation

public protocol BoardQuery {
    func checkNextIntersection(_ move: Move) -> (any ChessPiece)?
    func get(atRow: Int, atFile: Int) -> (any ChessPiece)?
    func isEmpty(atRow: Int, atFile: Int) -> Bool
    func isNotEmpty(atRow: Int, atFile: Int) -> Bool
}
