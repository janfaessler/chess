import Foundation

class King: Piece, @unchecked Sendable {

    static let CastleQueensidePosition = 3
    static let CastleKingsidePosition = 7

    init(color: PieceColor, row: Int, file: Int, moved: Bool = false) {
        super.init(type: .king, color: color, row: row, file: file, moved: moved)
    }

    override func getPossibleMoves() -> [Move] {
        let row = row
        let file = file
        var optionals: [Move?] = [
            createMove(row+1, file+1),
            createMove(row, file+1),
            createMove(row+1, file),
            createMove(row-1, file-1),
            createMove(row, file-1),
            createMove(row-1, file),
            createMove(row-1, file+1),
            createMove(row+1, file-1)
        ]
        if !hasMoved() {
            optionals += [
                createMove(row, King.CastleQueensidePosition, .castle),
                createMove(row, King.CastleKingsidePosition, .castle)
            ]
        }
        return optionals.compactMap { $0 }
    }

    override func isMovePossible(_ move: Move, position: Position) -> Bool {
        if CastlingRules.isCastlingMove(move) {
            return CastlingRules.canCastle(move, position: position)
        }
        return super.isMovePossible(move, position: position)
    }

    override func createMove(_ filename: any StringProtocol) -> Move? {
        let possibleMoves = getPossibleMoves()
        return possibleMoves.first(where: { $0.squareInfo == filename })
    }
}
