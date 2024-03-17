import Foundation

public class King : Figure {
    
    public static let Ident = "K"
    public static let CastleQueensideNotation = "O-O-O"
    public static let CastleKingsideNotation = "O-O"
    public static let CastleQueensidePosition = 3
    public static let CastleKingsidePosition = 7
    
    public init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .king, color: color, row: row, file: file, moved: moved)
    }
    
    public override func getPossibleMoves() -> [Move] {
        let row = getRow()
        let file = getFile()
        var moves = [
            createMove(row+1, file+1),
            createMove(row, file+1),
            createMove(row+1, file),
            createMove(row-1, file-1),
            createMove(row, file-1),
            createMove(row-1, file),
            createMove(row-1, file+1),
            createMove(row+1, file-1)
        ]
        if (!hasMoved()) {
            moves.append(contentsOf: [
                createMove(row, King.CastleQueensidePosition, MoveType.Castle),
                createMove(row, King.CastleKingsidePosition, MoveType.Castle)
            ])
        }
        return moves.filter({ move in inBoard(move) })
    }
    
    public override func isMovePossible( _ move: Move, position:Position) -> Bool {
        if isShortCastling(move) {
            return canCastle(move, rookStart: Rook.CastleKingsideStartingFile, cache: position)
        } else if isLongCastling(move) {
            return canCastle(move, rookStart: Rook.CastleQueensideStartingFile, cache: position)
        }
        return super.isMovePossible(move, position: position)
    }
    
    public override func createMove(_ filename: any StringProtocol) -> Move? {
        let possibleMoves = getPossibleMoves()
        return possibleMoves.first(where: {$0.getFieldInfo() == filename})
    }
    
    public override func ident() -> String {
        return King.Ident
    }
    
    private func canCastle(_ to: Move, rookStart:Int, cache:Position) -> Bool {
        if  isCastlingInCheck(to, cache:cache) {
            return false
        }
        
        if to.piece.getColor() == .white {
            return rookStart == Rook.CastleKingsideStartingFile ? cache.canWhiteCastleKingside() : cache.canWhiteCastleQueenside()
        } else {
            return rookStart == Rook.CastleKingsideStartingFile ? cache.canBlackCastleKingside() : cache.canBlackCastleQueenside()
        }
    }
    
    private func isLongCastling(_ move: Move) -> Bool {
        return move.file == King.CastleQueensidePosition && isKingCastling(move)
    }
    
    private func isShortCastling(_ move: Move) -> Bool {
        return move.file == King.CastleKingsidePosition && isKingCastling(move)
    }
    
    private func isKingCastling(_ move: Move) -> Bool {
        return move.piece.getType() == .king && move.type == .Castle
    }
    
    private func isCastlingInCheck(_ move:Move, cache:Position) -> Bool {
         
        let isLongCastle = isLongCastling(move)
        
        guard !cache.isFieldInCheck(move.piece.getRow(), move.piece.getFile()) else { return true }
        guard !cache.isFieldInCheck(move.row, isLongCastle ? move.file + 1 : move.file - 1) else { return true }
        guard !cache.isFieldInCheck(move.row, move.file) else { return true }
        
        return false
    }
}
