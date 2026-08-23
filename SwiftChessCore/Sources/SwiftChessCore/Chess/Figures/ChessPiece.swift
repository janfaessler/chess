import Foundation

public protocol ChessPiece: Hashable, Equatable, Sendable {
    var row: Int { get }
    var file: Int { get }
    var color: PieceColor { get }
    var type: PieceType { get }
    var square: Square { get }
    var squareInfo: String { get }
    func canDo(move: Move) -> Bool
    func getPossibleMoves() -> [Move]
    func isMovePossible(_ move: Move, position: Position) -> Bool
    func equals(_ other: any ChessPiece) -> Bool
    func hasMoved() -> Bool
    func info() -> String
    func createMove(_ row: Int, _ file: Int, _ type: MoveType) -> Move
    func createMove(_ move: any StringProtocol, type: MoveType, promoteTo: PieceType) -> Move?
    func createMove(_ move: any StringProtocol) -> Move?
}

extension ChessPiece {
    public func createMove(_ move: any StringProtocol, type: MoveType) -> Move? {
        createMove(move, type: type, promoteTo: .queen)
    }
}
