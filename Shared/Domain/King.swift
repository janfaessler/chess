import Foundation

public class King : Figure {
    
    public static let Ident = "K"
    public static let LongCastleNotation = "O-O-O"
    public static let ShortCastleNotation = "O-O"
    public static let LongCastlePosition = 3
    public static let ShortCastlePosition = 7
    
    public init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .king, color: color, row: row, file: file, moved: moved)
    }
    
    public override func getPossibleMoves() -> [Move] {
        let row = getRow()
        let file = getFile()
        var moves = [
            CreateMove(row+1, file+1),
            CreateMove(row, file+1),
            CreateMove(row+1, file),
            CreateMove(row-1, file-1),
            CreateMove(row, file-1),
            CreateMove(row-1, file),
            CreateMove(row-1, file+1),
            CreateMove(row+1, file-1)
        ]
        if (!hasMoved()) {
            moves.append(contentsOf: [
                createMove(row, King.LongCastlePosition, MoveType.Castle),
                createMove(row, King.ShortCastlePosition, MoveType.Castle)
            ])
        }
        return moves.filter({ move in inBoard(move) })
    }
    
    public override func isMovePossible( _ move: Move, cache:BoardCache) -> Bool {
        if isShortCastling(move) {
            return canCastle(move, rookStart: Rook.ShortCastleStartingFile, cache: cache)
        } else if isLongCastling(move) {
            return canCastle(move, rookStart: Rook.LongCastleStartingFile, cache: cache)
        }
        return super.isMovePossible(move, cache: cache)
    }
    
    public override func createMove(_ filename: any StringProtocol) -> Move? {
        let possibleMoves = getPossibleMoves()
        return possibleMoves.first(where: {$0.getFieldInfo() == filename})
    }
    
    public override func ident() -> String {
        return King.Ident
    }
    
    private func canCastle(_ to: Move, rookStart:Int, cache:BoardCache) -> Bool {
        let isNotCastlingInCheck = isCastlingInCheck(to, cache:cache) == false
        let kingHasNotMovedYet = self.hasMoved() == false
        let figureAtRookStart = cache.get(atRow: to.piece.getRow(), atFile: rookStart)
        let rookHasNotMovedYet = figureAtRookStart != nil && figureAtRookStart!.getType() == .rook && figureAtRookStart?.getColor() == getColor() && figureAtRookStart?.hasMoved() == false
        return isNotCastlingInCheck && kingHasNotMovedYet && rookHasNotMovedYet
    }
    
    private func isLongCastling(_ move: Move) -> Bool {
        return move.file == King.LongCastlePosition && isKingCastling(move)
    }
    
    private func isShortCastling(_ move: Move) -> Bool {
        return move.file == King.ShortCastlePosition && isKingCastling(move)
    }
    
    private func isKingCastling(_ move: Move) -> Bool {
        return move.piece.getType() == .king && move.type == .Castle
    }
    
    private func isCastlingInCheck(_ move:Move, cache:BoardCache) -> Bool {
         
        let isLongCastle = isLongCastling(move)
        
        guard !cache.isFieldInCheck(move.piece.getRow(), move.piece.getFile()) else { return true }
        guard !cache.isFieldInCheck(move.row, isLongCastle ? move.file + 1 : move.file - 1) else { return true }
        guard !cache.isFieldInCheck(move.row, move.file) else { return true }
        
        return false
    }
}
