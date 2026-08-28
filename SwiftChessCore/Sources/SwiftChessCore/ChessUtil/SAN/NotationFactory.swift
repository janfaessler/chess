import Foundation

public enum NotationFactory {

    public static func generate(_ move: Move, position: Position) -> String {
        guard !CastlingRules.isCastlingMove(move) else {
            return getCastlingNotation(move, position: position)
        }
        let newValidator = MoveValidator(position.applying(move))
        let validator = MoveValidator(position)
        let checkIdentifier = getCheckIdentifier(newValidator)
        let piece = getPieceIdentifier(move, position: position)
        let duplicateIdentifier = getDuplicateIdentifier(move, position: position, validator: validator)
        let captureIdentifier = getCaptureIdentifier(move, position: position)
        let square = move.squareInfo
        let promotionIdentifier = getPromotionIdentifier(move)
        return "\(piece)\(duplicateIdentifier)\(captureIdentifier)\(square)\(promotionIdentifier)\(checkIdentifier)"
    }

    private static func getCastlingNotation(_ move: Move, position: Position) -> String {
        if CastlingRules.isQueensideCastling(move) {
            return ChessNotation.queensideCastle
        } else if CastlingRules.isKingsideCastling(move) {
            return ChessNotation.kingsideCastle
        }
        return ""
    }

    private static func sanIdent(for type: PieceType) -> String {
        type == .pawn ? "" : String(type.char)
    }

    private static func getPieceIdentifier(_ move: Move, position: Position) -> String {
        if move.pieceType == .pawn {
            if isCapture(move, position: position) {
                return move.startingSquare.fileName
            } else {
                return ""
            }
        } else {
            return sanIdent(for: move.pieceType)
        }
    }

    private static func getCheckIdentifier(_ validator: MoveValidator) -> String {
        guard validator.isKingInCheck() else { return "" }
        return validator.playerHasLegalMove() ? String(ChessNotation.check) : String(ChessNotation.checkmate)
    }

    private static func getPromotionIdentifier(_ move: Move) -> String {
        guard move.type == .promotion else { return "" }
        return "\(ChessNotation.promotion)\(sanIdent(for: move.promoteTo.pieceType))"
    }

    private static func getCaptureIdentifier(_ move: Move, position: Position) -> String {
        return isCapture(move, position: position) ? String(ChessNotation.capture) : ""
    }

    private static func getDuplicateIdentifier(_ move: Move, position: Position, validator: MoveValidator) -> String {
        guard move.pieceType != .pawn else { return "" }

        let ambiguousPieces = getPiecesForPossibleMoveDuplicate(move, position: position, validator: validator)
        guard !ambiguousPieces.isEmpty else { return "" }

        let shareFile = ambiguousPieces.contains { $0.file == move.startingSquare.file }
        let shareRank = ambiguousPieces.contains { $0.row == move.startingSquare.row }
        if !shareFile {
            return move.startingSquare.fileName
        } else if !shareRank {
            return String(move.startingSquare.row)
        } else {
            return "\(move.startingSquare.fileName)\(move.startingSquare.row)"
        }
    }

    private static func getPiecesForPossibleMoveDuplicate(_ move: Move, position: Position, validator: MoveValidator) -> [any ChessPiece] {
        return position.figures.filter { figure in
            guard figure.color == move.color,
                  figure.type == move.pieceType,
                  figure.square != move.startingSquare,
                  let candidate = figure.createMove(move.squareInfo) else { return false }
            return validator.isLegalMove(candidate)
        }
    }

    private static func isCapture(_ move: Move, position: Position) -> Bool {
        let pieceAtPosition = position.get(atRow: move.row, atFile: move.file)
        return pieceAtPosition != nil || EnPassantRules.isEnPassant(move, board: position)
    }

}
