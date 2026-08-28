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
    func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool
    func equals(_ other: any ChessPiece) -> Bool
    func hasMoved() -> Bool
    func info() -> String
    func createMove(_ row: Int, _ file: Int, _ type: MoveType) -> Move?
    func createMove(_ row: Int, _ file: Int) -> Move?
    func createMove(_ move: any StringProtocol, type: MoveType, promoteTo: PromotionPiece) -> Move?
    func createMove(_ move: any StringProtocol) -> Move?
}

extension ChessPiece {
    public func createMove(_ move: any StringProtocol, type: MoveType) -> Move? {
        createMove(move, type: type, promoteTo: .queen)
    }

    public var square: Square {
        guard let s = Square(row: row, file: file) else {
            preconditionFailure("Square coordinate out of bounds: row=\(row) file=\(file)")
        }
        return s
    }

    public var squareInfo: String { square.info }

    public func equals(_ other: any ChessPiece) -> Bool {
        row == other.row && file == other.file && type == other.type && color == other.color
    }

    public func info() -> String { "(\(color) \(type) \(squareInfo))" }

    public func isCaptureablePiece(_ move: Move, pieceToCapture: any ChessPiece) -> Bool {
        move.color != pieceToCapture.color && pieceToCapture.row == move.row && pieceToCapture.file == move.file
    }

    public func canDo(move: Move) -> Bool {
        getPossibleMoves().contains(where: { $0.row == move.row && $0.file == move.file })
    }

    public func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool {
        guard canDo(move: move) else { return false }
        guard let intersectingPiece = board.checkNextIntersection(move) else { return true }
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
    }

    public func createMove(_ row: Int, _ file: Int) -> Move? {
        Move(row, file, startingSquare: self.square, color: self.color, pieceType: self.type, hasMoved: hasMoved(), type: .normal)
    }

    public func createMove(_ row: Int, _ file: Int, _ type: MoveType) -> Move? {
        Move(row, file, startingSquare: self.square, color: self.color, pieceType: self.type, hasMoved: hasMoved(), type: type)
    }

    public func createMove(_ move: any StringProtocol, type: MoveType, promoteTo: PromotionPiece) -> Move? {
        Move(move, startingSquare: self.square, color: self.color, pieceType: self.type, hasMoved: hasMoved(), type: type, promoteTo: promoteTo)
    }

    public func createMove(_ move: any StringProtocol) -> Move? {
        createMove(move, type: .normal)
    }
}
