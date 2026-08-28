import Foundation

public struct Rook: ChessPiece, Sendable {
    public let color: PieceColor
    public let row: Int
    public let file: Int
    private let moved: Bool

    public var type: PieceType { .rook }

    init(color: PieceColor, row: Int, file: Int, moved: Bool = false) {
        self.color = color
        self.row = row
        self.file = file
        self.moved = moved
    }

    public func hasMoved() -> Bool { moved }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(color)
        hasher.combine(row)
        hasher.combine(file)
    }

    public func canDo(move: Move) -> Bool {
        (move.row == row) != (move.file == file)
    }

    public func getPossibleMoves() -> [Move] {
        SlidingMoves.along(rays: [(1, 0), (-1, 0), (0, 1), (0, -1)], piece: self)
    }
}
