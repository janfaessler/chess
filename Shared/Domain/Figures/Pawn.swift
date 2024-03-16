import Foundation

public class Pawn : Figure {
    
    public static let RowWherePromotionIsPossibleForWhite = 7
    public static let RowWherePromotionIsPossibleForBlack = 2
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .pawn, color: color, row: row, file: file, moved: moved)
    }
    
    public override func getPossibleMoves() -> [Move] {
        let row = getRow()
        let file = getFile()
        switch getColor() {
        case.black:
            let moveType = row == Pawn.RowWherePromotionIsPossibleForBlack ? MoveType.Promotion : MoveType.Normal
            var moves = [
                createMove(row-1, file-1, moveType),
                createMove(row-1, file, moveType),
                createMove(row-1, file+1, moveType)]
            if row == 7 {
                moves.append(createMove(row-2, file, MoveType.Double))
            }
            return moves
        case .white:
            let moveType = row == Pawn.RowWherePromotionIsPossibleForWhite ? MoveType.Promotion : MoveType.Normal
            var moves = [
                createMove(row+1, file-1, moveType),
                createMove(row+1, file, moveType),
                createMove(row+1, file+1, moveType)]
            if row == 2 {
                moves.append(createMove(row+2, file, MoveType.Double))
            }
            return moves
        }
    }
    
    public override func isMovePossible( _ move: Move, cache:BoardCache) -> Bool {
        guard canDo(move: move) else { return false }
        let once = canMoveOnce(move, cache: cache)
        let twice = canMoveTwice(move, cache: cache)
        let capture = canCapture(move, cache: cache)
        return once || twice || capture
    }
    
    public override func createMove(_ move:any StringProtocol) -> Move? {
        return Move(move, piece: self, type: getMoveType(move))
    }
    
    public override func ident() -> String {
        return ""
    }
    
    private func canMoveOnce(_ move: Move, cache:BoardCache) -> Bool {
        guard move.type == .Normal else { return false }
        guard moveDoesNotChangeFile(move) else { return false }
        return cache.isEmpty(atRow: move.row, atFile: move.file)
    }
    
    private func canMoveTwice(_ move: Move, cache:BoardCache) -> Bool {
        guard move.type == .Double else { return false }
        guard !move.piece.hasMoved() else { return false }
        guard moveDoesNotChangeFile(move) else { return false }
        guard cache.isEmpty(atRow: move.row, atFile: move.file) else { return false }
        
        if move.piece.getColor() == PieceColor.white {
            return cache.isEmpty(atRow: move.piece.getRow()+1, atFile: move.file)
        } else {
            return cache.isEmpty(atRow: move.piece.getRow()-1, atFile: move.file)
        }
    }
    
    private func canCapture(_ move:Move, cache:BoardCache) -> Bool {
        guard move.type == .Normal || move.type == .Promotion else { return false }
        
        let row = move.piece.getRow() + (move.piece.getColor() == PieceColor.white ? +1 : -1)
        let leftFile = move.piece.getFile() - 1
        let rightFile = move.piece.getFile() + 1
        
        let figureToCaptureOnLeft = cache.isNotEmpty(atRow: row, atFile: leftFile)
        let figureToCaptureOnRight = cache.isNotEmpty(atRow: row, atFile: rightFile)
        
        
        let canEnPassant = canEnPassant(move, cache:cache)
        
        return (figureToCaptureOnLeft && leftFile == move.file) || (figureToCaptureOnRight && rightFile == move.file) || canEnPassant
    }
    
    private func canEnPassant(_ move:Move, cache:BoardCache) -> Bool {
        guard let target = cache.getEnPassentTarget() else { return false }
        
        return move.getField() == target
    }
    
    private func moveDoesNotChangeFile(_ move:Move) -> Bool {
        return move.file == move.piece.getFile()
    }
    
    private func getMoveType(_ move: any StringProtocol) -> MoveType {
        return abs(Int(String(Array(move).last!))! - getRow()) == 2 ? MoveType.Double : MoveType.Normal
    }
}
