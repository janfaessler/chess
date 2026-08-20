import Foundation

class Pawn : Figure {
    
    static let RowWherePromotionIsPossibleForWhite = 7
    static let RowWherePromotionIsPossibleForBlack = 2
    static let startingRowForWhite = 2
    static let startingRowForBlack = 7
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .pawn, color: color, row: row, file: file, moved: moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        let row = row
        let file = file
        switch color {
        case.black:
            let moveType = row == Pawn.RowWherePromotionIsPossibleForBlack ? MoveType.Promotion : MoveType.Normal
            var moves = [
                createMove(row-1, file-1, moveType),
                createMove(row-1, file, moveType),
                createMove(row-1, file+1, moveType)]
            if row == Pawn.startingRowForBlack {
                moves.append(createMove(row-2, file, MoveType.Double))
            }
            return moves
        case .white:
            let moveType = row == Pawn.RowWherePromotionIsPossibleForWhite ? MoveType.Promotion : MoveType.Normal
            var moves = [
                createMove(row+1, file-1, moveType),
                createMove(row+1, file, moveType),
                createMove(row+1, file+1, moveType)]
            if row == Pawn.startingRowForWhite {
                moves.append(createMove(row+2, file, MoveType.Double))
            }
            return moves
        }
    }
    
    override func isMovePossible( _ move: Move, position:Position) -> Bool {
        guard canDo(move: move) else { return false }
        let once = canMoveOnce(move, position: position)
        let twice = canMoveTwice(move, position: position)
        let capture = canCapture(move, position: position)
        return once || twice || capture
    }
    
    override func createMove(_ move:any StringProtocol) -> Move? {
        return Move(move, piece: Pawn(color: self.color, row: self.row, file: self.file), type: getMoveType(move))
    }

    private func canMoveOnce(_ move: Move, position:Position) -> Bool {
        guard move.type == .Normal || move.type == .Promotion else { return false }
        guard moveDoesNotChangeFile(move) else { return false }
        return position.isEmpty(atRow: move.row, atFile: move.file)
    }
    
    private func canMoveTwice(_ move: Move, position:Position) -> Bool {
        guard move.type == .Double else { return false }
        guard !move.piece.hasMoved() else { return false }
        guard moveDoesNotChangeFile(move) else { return false }
        guard position.isEmpty(atRow: move.row, atFile: move.file) else { return false }
        
        if move.piece.color == PieceColor.white {
            return position.isEmpty(atRow: move.piece.row+1, atFile: move.file)
        } else {
            return position.isEmpty(atRow: move.piece.row-1, atFile: move.file)
        }
    }
    
    private func canCapture(_ move:Move, position:Position) -> Bool {
        guard move.type == .Normal || move.type == .Promotion else { return false }

        let row = move.piece.row + (move.piece.color == PieceColor.white ? +1 : -1)
        let leftFile = move.piece.file - 1
        let rightFile = move.piece.file + 1

        let enemyToCaptureOnLeft = hasEnemy(atRow: row, atFile: leftFile, position: position)
        let enemyToCaptureOnRight = hasEnemy(atRow: row, atFile: rightFile, position: position)


        let canEnPassant = EnPassantRules.canEnPassant(move, position: position)

        return (enemyToCaptureOnLeft && leftFile == move.file) || (enemyToCaptureOnRight && rightFile == move.file) || canEnPassant
    }

    private func hasEnemy(atRow row: Int, atFile file: Int, position: Position) -> Bool {
        guard let target = position.get(atRow: row, atFile: file) else { return false }
        return target.color != color
    }
    

    
    private func moveDoesNotChangeFile(_ move:Move) -> Bool {
        return move.file == move.piece.file
    }
    
    private func getMoveType(_ move: any StringProtocol) -> MoveType {
        guard let lastChar = move.last, let targetRow = Int(String(lastChar)) else { return .Normal }
        return abs(targetRow - row) == 2 ? .Double : .Normal
    }
}
