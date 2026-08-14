import Foundation

struct CastlingRules {

    static func isCastlingMove(_ move: Move) -> Bool {
        move.piece.getType() == .king && move.type == .Castle
    }

    static func isKingsideCastling(_ move: Move) -> Bool {
        isCastlingMove(move) && move.file == King.CastleKingsidePosition
    }

    static func isQueensideCastling(_ move: Move) -> Bool {
        isCastlingMove(move) && move.file == King.CastleQueensidePosition
    }

    static func castlingRookMove(for move: Move) -> (fromFile: Int, toFile: Int)? {
        guard isCastlingMove(move) else { return nil }
        return isQueensideCastling(move)
            ? (Rook.CastleQueensideStartingFile, Rook.CastleQueensideEndFile)
            : (Rook.CastleKingsideStartingFile, Rook.CastleKingsideEndFile)
    }

    static func pathIsInCheck(_ move: Move, position: Position) -> Bool {
        let row = move.piece.getRow()
        return position.isFieldInCheck(row, move.piece.getFile())
            || position.isFieldInCheck(row, transitFile(for: move))
            || position.isFieldInCheck(row, move.file)
    }

    static func canCastle(_ move: Move, position: Position) -> Bool {
        guard isCastlingMove(move) else { return false }
        guard hasRights(move, position: position) else { return false }
        guard pathIsClear(move, position: position) else { return false }
        guard !pathIsInCheck(move, position: position) else { return false }
        return true
    }

    static func retainsRights(afterMove move: Move, color: PieceColor, rookStartingFile: Int, capturedPiece: (any ChessFigure)?, oldPosition: Position) -> Bool {
        guard rightsState(oldPosition, color: color, rookStartingFile: rookStartingFile) else { return false }
        if move.piece.getColor() == color && move.piece.getType() == .king { return false }
        if move.piece.getColor() == color && move.piece.getType() == .rook && move.piece.getFile() == rookStartingFile { return false }
        if let captured = capturedPiece, captured.getColor() == color, captured.getType() == .rook {
            if captured.getFile() == Rook.CastleKingsideStartingFile || captured.getFile() == Rook.CastleQueensideStartingFile { return false }
        }
        return true
    }

    private static func hasRights(_ move: Move, position: Position) -> Bool {
        if move.piece.getColor() == .white {
            return isKingsideCastling(move) ? position.canWhiteCastleKingside() : position.canWhiteCastleQueenside()
        } else {
            return isKingsideCastling(move) ? position.canBlackCastleKingside() : position.canBlackCastleQueenside()
        }
    }

    private static func pathIsClear(_ move: Move, position: Position) -> Bool {
        let rookFile = isKingsideCastling(move) ? Rook.CastleKingsideStartingFile : Rook.CastleQueensideStartingFile
        let kingFile = move.piece.getFile()
        let row = move.piece.getRow()
        let lo = min(kingFile, rookFile) + 1
        let hi = max(kingFile, rookFile)
        return (lo..<hi).allSatisfy { position.isEmpty(atRow: row, atFile: $0) }
    }

    private static func rightsState(_ position: Position, color: PieceColor, rookStartingFile: Int) -> Bool {
        if color == .white {
            return rookStartingFile == Rook.CastleKingsideStartingFile ? position.canWhiteCastleKingside() : position.canWhiteCastleQueenside()
        } else {
            return rookStartingFile == Rook.CastleKingsideStartingFile ? position.canBlackCastleKingside() : position.canBlackCastleQueenside()
        }
    }
    
    private static func transitFile(for move: Move) -> Int {
        isKingsideCastling(move) ? move.file - 1 : move.file + 1
    }
}
