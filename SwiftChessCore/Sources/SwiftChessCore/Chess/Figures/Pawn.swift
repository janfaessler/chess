import Foundation

class Pawn: Piece, @unchecked Sendable {

    static let startingRowForWhite = 2
    static let startingRowForBlack = 7

    init(color: PieceColor, row: Int, file: Int, moved: Bool = false) {
        super.init(type: .pawn, color: color, row: row, file: file, moved: moved)
    }

    override func getPossibleMoves() -> [Move] {
        let row = row
        let file = file
        let moveType: MoveType = isOnPromotionRank ? .promotion : .normal
        switch color {
        case .black:
            var optionals: [Move?] = [
                createMove(row-1, file-1, moveType),
                createMove(row-1, file, moveType),
                createMove(row-1, file+1, moveType)]
            if row == Pawn.startingRowForBlack {
                optionals.append(createMove(row-2, file, .double))
            }
            return optionals.compactMap { $0 }
        case .white:
            var optionals: [Move?] = [
                createMove(row+1, file-1, moveType),
                createMove(row+1, file, moveType),
                createMove(row+1, file+1, moveType)]
            if row == Pawn.startingRowForWhite {
                optionals.append(createMove(row+2, file, .double))
            }
            return optionals.compactMap { $0 }
        }
    }

    override func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool {
        guard canDo(move: move) else { return false }
        let once = canMoveOnce(move, board: board)
        let twice = canMoveTwice(move, board: board)
        let capture = canCapture(move, board: board)
        return once || twice || capture
    }

    override func createMove(_ move: any StringProtocol) -> Move? {
        return Move(move, piece: Pawn(color: self.color, row: self.row, file: self.file), type: getMoveType(move))
    }

    private func canMoveOnce(_ move: Move, board: any BoardQuery) -> Bool {
        guard move.type == .normal || move.type == .promotion else { return false }
        guard moveDoesNotChangeFile(move) else { return false }
        return board.isEmpty(atRow: move.row, atFile: move.file)
    }

    private func canMoveTwice(_ move: Move, board: any BoardQuery) -> Bool {
        guard move.type == .double else { return false }
        guard !move.piece.hasMoved() else { return false }
        guard moveDoesNotChangeFile(move) else { return false }
        guard board.isEmpty(atRow: move.row, atFile: move.file) else { return false }

        if move.piece.color == PieceColor.white {
            return board.isEmpty(atRow: move.piece.row+1, atFile: move.file)
        } else {
            return board.isEmpty(atRow: move.piece.row-1, atFile: move.file)
        }
    }

    private func canCapture(_ move: Move, board: any BoardQuery) -> Bool {
        guard move.type == .normal || move.type == .promotion else { return false }

        let row = move.piece.row + (move.piece.color == PieceColor.white ? +1 : -1)
        let leftFile = move.piece.file - 1
        let rightFile = move.piece.file + 1

        let enemyToCaptureOnLeft = hasEnemy(atRow: row, atFile: leftFile, board: board)
        let enemyToCaptureOnRight = hasEnemy(atRow: row, atFile: rightFile, board: board)
        let canEnPassant = (board as? Position).map { EnPassantRules.canEnPassant(move, position: $0) } ?? false

        return (enemyToCaptureOnLeft && leftFile == move.file) || (enemyToCaptureOnRight && rightFile == move.file) || canEnPassant
    }

    private func hasEnemy(atRow row: Int, atFile file: Int, board: any BoardQuery) -> Bool {
        guard let target = board.get(atRow: row, atFile: file) else { return false }
        return target.color != color
    }

    private func moveDoesNotChangeFile(_ move: Move) -> Bool {
        return move.file == move.piece.file
    }

    private func getMoveType(_ move: any StringProtocol) -> MoveType {
        guard let lastChar = move.last, let targetRow = Int(String(lastChar)) else { return .normal }
        return abs(targetRow - row) == 2 ? .double : .normal
    }

    private var isOnPromotionRank: Bool {
        PromotionRules.isOnRankBeforePromotion(self)
    }
}
