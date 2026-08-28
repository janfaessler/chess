import Foundation

public struct Pawn: ChessPiece, Sendable {
    public let color: PieceColor
    public let row: Int
    public let file: Int
    private let moved: Bool

    public var type: PieceType { .pawn }

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
        let moveType: MoveType = isOnPromotionRank ? .promotion : .normal
        var moves: [Move] = []
        moves.reserveCapacity(4)
        switch color {
        case .black:
            if let m = createMove(row-1, file-1, moveType) { moves.append(m) }
            if let m = createMove(row-1, file, moveType) { moves.append(m) }
            if let m = createMove(row-1, file+1, moveType) { moves.append(m) }
            if row == BoardConstants.pawnStartingRowBlack, let m = createMove(row-2, file, .double) { moves.append(m) }
        case .white:
            if let m = createMove(row+1, file-1, moveType) { moves.append(m) }
            if let m = createMove(row+1, file, moveType) { moves.append(m) }
            if let m = createMove(row+1, file+1, moveType) { moves.append(m) }
            if row == BoardConstants.pawnStartingRowWhite, let m = createMove(row+2, file, .double) { moves.append(m) }
        }
        return moves
    }

    public func canDo(move: Move) -> Bool {
        let direction = color == .white ? 1 : -1
        let dr = move.row - row
        let df = abs(move.file - file)
        if dr == direction && df <= 1 { return true }
        if dr == 2 * direction && df == 0 { return true }
        return false
    }

    public func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool {
        guard canDo(move: move) else { return false }
        return canMoveOnce(move, board: board) || canMoveTwice(move, board: board) || canCapture(move, board: board)
    }

    public func createMove(_ move: any StringProtocol) -> Move? {
        Move(move, startingSquare: square, color: color, pieceType: .pawn, hasMoved: moved, type: getMoveType(move), promoteTo: .queen)
    }

    private func canMoveOnce(_ move: Move, board: any BoardQuery) -> Bool {
        guard move.type == .normal || move.type == .promotion else { return false }
        guard move.file == file else { return false }
        return board.isEmpty(atRow: move.row, atFile: move.file)
    }

    private func canMoveTwice(_ move: Move, board: any BoardQuery) -> Bool {
        guard move.type == .double else { return false }
        guard !moved else { return false }
        guard move.file == file else { return false }
        guard board.isEmpty(atRow: move.row, atFile: move.file) else { return false }
        if color == .white {
            return board.isEmpty(atRow: row+1, atFile: move.file)
        } else {
            return board.isEmpty(atRow: row-1, atFile: move.file)
        }
    }

    private func canCapture(_ move: Move, board: any BoardQuery) -> Bool {
        guard move.type == .normal || move.type == .promotion else { return false }
        let captureRow = row + (color == .white ? +1 : -1)
        let leftFile = file - 1
        let rightFile = file + 1
        let enemyLeft = hasEnemy(atRow: captureRow, atFile: leftFile, board: board)
        let enemyRight = hasEnemy(atRow: captureRow, atFile: rightFile, board: board)
        let canEnPassant = EnPassantRules.canEnPassant(move, board: board)
        return (enemyLeft && leftFile == move.file) || (enemyRight && rightFile == move.file) || canEnPassant
    }

    private func hasEnemy(atRow r: Int, atFile f: Int, board: any BoardQuery) -> Bool {
        guard let target = board.get(atRow: r, atFile: f) else { return false }
        return target.color != color
    }

    private func getMoveType(_ move: any StringProtocol) -> MoveType {
        guard let lastChar = move.last, let targetRow = Int(String(lastChar)) else { return .normal }
        return abs(targetRow - row) == 2 ? .double : .normal
    }

    private var isOnPromotionRank: Bool {
        PromotionRules.isOnRankBeforePromotion(self)
    }
}
