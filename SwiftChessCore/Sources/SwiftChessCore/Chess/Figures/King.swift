import Foundation

public struct King: ChessPiece, Sendable {
    public let color: PieceColor
    public let row: Int
    public let file: Int
    private let moved: Bool

    public var type: PieceType { .king }

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

    public func getPossibleMoves() -> [Move] {
        var moves: [Move] = []
        moves.reserveCapacity(10)
        if let m = createMove(row+1, file+1) { moves.append(m) }
        if let m = createMove(row, file+1) { moves.append(m) }
        if let m = createMove(row+1, file) { moves.append(m) }
        if let m = createMove(row-1, file-1) { moves.append(m) }
        if let m = createMove(row, file-1) { moves.append(m) }
        if let m = createMove(row-1, file) { moves.append(m) }
        if let m = createMove(row-1, file+1) { moves.append(m) }
        if let m = createMove(row+1, file-1) { moves.append(m) }
        if !moved {
            if let m = createMove(row, BoardConstants.kingCastleQueensideFile, .castle) { moves.append(m) }
            if let m = createMove(row, BoardConstants.kingCastleKingsideFile, .castle) { moves.append(m) }
        }
        return moves
    }

    public func canDo(move: Move) -> Bool {
        let dr = abs(move.row - row)
        let df = abs(move.file - file)
        if dr <= 1 && df <= 1 && dr + df > 0 { return true }
        guard !moved, move.type == .castle, move.row == row else { return false }
        return move.file == BoardConstants.kingCastleKingsideFile || move.file == BoardConstants.kingCastleQueensideFile
    }

    public func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool {
        if CastlingRules.isCastlingMove(move) {
            return CastlingRules.canCastle(move, board: board)
        }
        guard canDo(move: move) else { return false }
        guard let intersectingPiece = board.checkNextIntersection(move) else { return true }
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
    }

    public func createMove(_ move: any StringProtocol) -> Move? {
        getPossibleMoves().first(where: { $0.squareInfo == move })
    }
}
