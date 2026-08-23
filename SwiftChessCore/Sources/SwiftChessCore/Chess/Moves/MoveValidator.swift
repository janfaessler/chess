import Foundation

struct MoveValidator {

    let position: Position

    init(_ position: Position) {
        self.position = position
    }

    func isLegalMove(_ target: Move) -> Bool {
        guard isMoveInBoard(target) else { return false }
        guard target.piece.isMovePossible(target, position: position) else { return false }
        guard !doesMovePutOwnKingInCheck(target) else { return false }
        return true
    }

    func isCheck(_ move: Move) -> Bool {
        guard let opponentKing = position.figures.first(where: { $0.type == .king && $0.color != move.piece.color }) else { return false }
        let newPosition = position.applying(move)
        return MoveValidator(newPosition).isFieldInCheck(opponentKing.row, opponentKing.file)
    }

    func isCheckMate(_ move: Move) -> Bool {
        let validator = MoveValidator(position.applying(move))
        return !validator.playerHasLegalMove() && validator.isKingInCheck()
    }

    func isFieldInCheck(_ row: Int, _ file: Int) -> Bool {
        return position.figures.contains(where: {
            if $0.color == position.colorToMove { return false }
            return $0.isMovePossible(Move(row, file, piece: $0), position: position)
        })
    }

    func playerHasLegalMove() -> Bool {
        let figuresOfCurrentPlayer = position.figures.filter({ $0.color == position.colorToMove })
        return figuresOfCurrentPlayer.contains(where: { fig in fig.getPossibleMoves().contains(where: { move in isLegalMove(move) }) })
    }

    func isKingInCheck() -> Bool {
        guard let king = position.figures.first(where: { $0.type == .king && $0.color == position.colorToMove }) else { return false }
        return isFieldInCheck(king.row, king.file)
    }
    
    func figureExists(_ move: Move) -> Bool {
        return self.position.get(atRow: move.piece.row, atFile: move.piece.file) != nil
    }

    private func doesMovePutOwnKingInCheck(_ move: Move) -> Bool {
        if CastlingRules.isCastlingMove(move) {
            return CastlingRules.pathIsInCheck(move, position: position)
        }

        let figures = position.figures
        guard let king = figures.first(where: { $0.type == .king && $0.color == move.piece.color }) else { return true }
        let isKingMove = move.piece.type == .king
        let rowToCheck = isKingMove ? move.row : king.row
        let fileToCheck = isKingMove ? move.file : king.file
        let newPos = position.applying(move)

        return figures.contains(where: {
            guard $0.color != position.colorToMove else { return false }
            return $0.isMovePossible($0.createMove(rowToCheck, fileToCheck, MoveType.normal), position: newPos)
        })
    }

    private func isMoveInBoard(_ move: Move) -> Bool {
        return 1...8 ~= move.row && 1...8 ~= move.file
    }
}
