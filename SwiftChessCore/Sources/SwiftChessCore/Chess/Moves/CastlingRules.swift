import Foundation

struct CastlingRules {

    static func isCastlingMove(_ move: Move) -> Bool {
        move.piece.type == .king && move.type == .castle
    }

    static func isKingsideCastling(_ move: Move) -> Bool {
        isCastlingMove(move) && move.file == BoardConstants.kingCastleKingsideFile
    }

    static func isQueensideCastling(_ move: Move) -> Bool {
        isCastlingMove(move) && move.file == BoardConstants.kingCastleQueensideFile
    }

    static func castlingRookMove(for move: Move) -> (fromFile: Int, toFile: Int)? {
        guard isCastlingMove(move) else { return nil }
        return isQueensideCastling(move)
            ? (BoardConstants.rookCastleQueensideStartFile, BoardConstants.rookCastleQueensideEndFile)
            : (BoardConstants.rookCastleKingsideStartFile, BoardConstants.rookCastleKingsideEndFile)
    }

    static func pathIsInCheck(_ move: Move, position: Position) -> Bool {
        let row = move.piece.row
        let validator = MoveValidator(position)
        return validator.isSquareAttackedByOpponent(row: row, file: move.piece.file)
            || validator.isSquareAttackedByOpponent(row: row, file: transitFile(for: move))
            || validator.isSquareAttackedByOpponent(row: row, file: move.file)
    }

    static func canCastle(_ move: Move, board: any BoardQuery) -> Bool {
        guard isCastlingMove(move) else { return false }
        guard board.castlingRights.canCastle(kingside: isKingsideCastling(move), for: move.piece.color) else { return false }
        guard pathIsClear(move, board: board) else { return false }
        if let position = board as? Position {
            guard !pathIsInCheck(move, position: position) else { return false }
        }
        return true
    }

    static func updatedRights(afterMove move: Move, capturedPiece: (any ChessPiece)?, oldPosition: Position) -> CastlingRights {
        let old = oldPosition.castlingRights
        return CastlingRights(
            whiteKingside:  retainsRight(afterMove: move, kingside: true,  color: .white, capturedPiece: capturedPiece, old: old),
            whiteQueenside: retainsRight(afterMove: move, kingside: false, color: .white, capturedPiece: capturedPiece, old: old),
            blackKingside:  retainsRight(afterMove: move, kingside: true,  color: .black, capturedPiece: capturedPiece, old: old),
            blackQueenside: retainsRight(afterMove: move, kingside: false, color: .black, capturedPiece: capturedPiece, old: old)
        )
    }

    private static func retainsRight(afterMove move: Move, kingside: Bool, color: PieceColor, capturedPiece: (any ChessPiece)?, old: CastlingRights) -> Bool {
        guard old.canCastle(kingside: kingside, for: color) else { return false }
        if move.piece.color == color && move.piece.type == .king { return false }
        let rookFile = kingside ? BoardConstants.rookCastleKingsideStartFile : BoardConstants.rookCastleQueensideStartFile
        if move.piece.color == color && move.piece.type == .rook && move.piece.file == rookFile { return false }
        if let captured = capturedPiece, captured.color == color, captured.type == .rook {
            if captured.file == BoardConstants.rookCastleKingsideStartFile || captured.file == BoardConstants.rookCastleQueensideStartFile { return false }
        }
        return true
    }

    private static func pathIsClear(_ move: Move, board: any BoardQuery) -> Bool {
        let rookFile = isKingsideCastling(move) ? BoardConstants.rookCastleKingsideStartFile : BoardConstants.rookCastleQueensideStartFile
        let kingFile = move.piece.file
        let row = move.piece.row
        let lo = min(kingFile, rookFile) + 1
        let hi = max(kingFile, rookFile)
        return (lo..<hi).allSatisfy { board.isEmpty(atRow: row, atFile: $0) }
    }

    private static func transitFile(for move: Move) -> Int {
        isKingsideCastling(move) ? move.file - 1 : move.file + 1
    }
}
