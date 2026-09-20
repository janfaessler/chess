import Foundation

struct MoveValidator {

    let position: Position

    init(_ position: Position) {
        self.position = position
    }

    func isLegalMove(_ target: Move) -> Bool {
        resultingPositionIfLegal(target) != nil
    }

    func resultingPositionIfLegal(_ move: Move) -> Position? {
        guard move.color == position.colorToMove else { return nil }
        guard let piece = position.get(atRow: move.startingSquare.row, atFile: move.startingSquare.file) else { return nil }
        guard piece.isMovePossible(move, board: position) else { return nil }

        if CastlingRules.isCastlingMove(move) {
            guard !CastlingRules.pathIsInCheck(move, position: position) else { return nil }
            return position.applying(move)
        }

        guard let king = position.figures.first(where: { $0.type == .king && $0.color == move.color }) else { return nil }
        let isKingMove = move.pieceType == .king
        let rowToCheck = isKingMove ? move.row : king.row
        let fileToCheck = isKingMove ? move.file : king.file
        let newPosition = position.applying(move)

        let putsOwnKingInCheck = newPosition.figures.contains(where: {
            guard $0.color != position.colorToMove else { return false }
            return $0.attacksSquare(row: rowToCheck, file: fileToCheck, board: newPosition)
        })
        return putsOwnKingInCheck ? nil : newPosition
    }

    func isCheck(_ move: Move) -> Bool {
        guard let opponentKing = position.figures.first(where: { $0.type == .king && $0.color != move.color }) else { return false }
        let newPosition = position.applying(move)
        return MoveValidator(newPosition).isSquareAttackedByOpponent(row: opponentKing.row, file: opponentKing.file)
    }

    func isCheckMate(_ move: Move) -> Bool {
        let validator = MoveValidator(position.applying(move))
        return !validator.playerHasLegalMove() && validator.isKingInCheck()
    }

    func isSquareAttackedByOpponent(row: Int, file: Int) -> Bool {
        return position.figures.contains(where: {
            guard $0.color != position.colorToMove else { return false }
            return $0.attacksSquare(row: row, file: file, board: position)
        })
    }

    func playerHasLegalMove() -> Bool {
        return position.figures.contains(where: { fig in
            guard fig.color == position.colorToMove else { return false }
            return fig.getPossibleMoves().contains(where: { isLegalMove($0) })
        })
    }

    func isKingInCheck() -> Bool {
        guard let king = position.figures.first(where: { $0.type == .king && $0.color == position.colorToMove }) else { return false }
        return isSquareAttackedByOpponent(row: king.row, file: king.file)
    }

    func figureExists(_ move: Move) -> Bool {
        return self.position.get(atRow: move.startingSquare.row, atFile: move.startingSquare.file) != nil
    }

}
