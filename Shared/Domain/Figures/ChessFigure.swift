import Foundation

public protocol ChessFigure : Hashable, Equatable {
    func move(row:Int, file:Int)
    func canDo(move:Move) -> Bool
    func getPossibleMoves() -> [Move]
    func isMovePossible(_ move: Move, position:Position) -> Bool
    func getRow() -> Int
    func getFile() -> Int
    func getColor() -> PieceColor
    func getType() -> PieceType
    func equals(_ other:any ChessFigure) -> Bool
    func getField() -> Field
    func getFieldInfo() -> String
    func hasMoved() -> Bool
    func info() -> String
    func ident() -> String
    func createMove(_ row:Int, _ file:Int, _ type:MoveType) -> Move
    func createMove(_ move:any StringProtocol, type:MoveType) -> Move?
    func createMove(_ move:any StringProtocol, type:MoveType, promoteTo:PieceType) -> Move?
    func createMove(_ filename:any StringProtocol) -> Move?
    func hash(into hasher: inout Hasher)
}
