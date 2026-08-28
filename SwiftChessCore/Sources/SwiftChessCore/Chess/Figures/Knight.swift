import Foundation

public struct Knight: ChessPiece, Sendable {
    public let color: PieceColor
    public let row: Int
    public let file: Int
    private let moved: Bool

    public var type: PieceType { .knight }

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
        let dr = abs(move.row - row)
        let df = abs(move.file - file)
        return (dr == 1 && df == 2) || (dr == 2 && df == 1)
    }

    public func getPossibleMoves() -> [Move] {
        var moves: [Move] = []
        moves.reserveCapacity(8)
        if let m = createMove(row+1, file+2) { moves.append(m) }
        if let m = createMove(row+1, file-2) { moves.append(m) }
        if let m = createMove(row-1, file+2) { moves.append(m) }
        if let m = createMove(row-1, file-2) { moves.append(m) }
        if let m = createMove(row+2, file+1) { moves.append(m) }
        if let m = createMove(row+2, file-1) { moves.append(m) }
        if let m = createMove(row-2, file+1) { moves.append(m) }
        if let m = createMove(row-2, file-1) { moves.append(m) }
        return moves
    }

    public func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool {
        guard canDo(move: move) else { return false }
        guard let pieceAtTarget = board.checkNextIntersection(move) else { return true }
        return isCaptureablePiece(move, pieceToCapture: pieceAtTarget)
    }
}
