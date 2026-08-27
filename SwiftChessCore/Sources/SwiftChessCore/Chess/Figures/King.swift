import Foundation

class King: Piece, @unchecked Sendable {

    init(color: PieceColor, row: Int, file: Int, moved: Bool = false) {
        super.init(type: .king, color: color, row: row, file: file, moved: moved)
    }

    override func getPossibleMoves() -> [Move] {
        let row = row
        let file = file
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
        if !hasMoved() {
            if let m = createMove(row, BoardConstants.kingCastleQueensideFile, .castle) { moves.append(m) }
            if let m = createMove(row, BoardConstants.kingCastleKingsideFile, .castle) { moves.append(m) }
        }
        return moves
    }

    override func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool {
        if CastlingRules.isCastlingMove(move) {
            return CastlingRules.canCastle(move, board: board)
        }
        return super.isMovePossible(move, board: board)
    }

    override func createMove(_ filename: any StringProtocol) -> Move? {
        let possibleMoves = getPossibleMoves()
        return possibleMoves.first(where: { $0.squareInfo == filename })
    }
}
