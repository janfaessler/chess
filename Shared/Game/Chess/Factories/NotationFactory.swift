import Foundation

class NotationFactory {
    
    static let LongCastle = "O-O-O"
    static let ShortCastle = "O-O"
    static let Capture:Character = "x"
    static let Promotion:Character = "="
    static let Check:Character = "+"
    static let Checkmate:Character = "#"
    
    static func generate(_ move:Move, position:Position) -> String {
        guard !CastlingRules.isCastlingMove(move) else {
            return getCastlingNotation(move, position:position)
        }
        let checkIdentifier = getCheckIdentifier(move, position: position)

        let piece = getPieceIdentifier(move, position: position)
        let duplicateIdentifier = getDuplicateIdentifier(move, position: position)
        let captureIdentifier = getCaptureIdentifier(move, position: position)
        let field = move.fieldInfo
        let promotionIdentifier = getPromotionIdentifier(move)
        return "\(piece)\(duplicateIdentifier)\(captureIdentifier)\(field)\(promotionIdentifier)\(checkIdentifier)"
    }
    
    private static func getCastlingNotation(_ move:Move, position:Position) -> String {
        if CastlingRules.isQueensideCastling(move) {
            return LongCastle
        } else if CastlingRules.isKingsideCastling(move) {
            return ShortCastle
        }
        return ""
    }
    
    private static func getPieceIdentifier(_ move:Move, position:Position) -> String {
        if move.piece.type == .pawn {
            if isCapture(move, position: position) {
                return move.piece.field.fileName
            } else {
                return ""
            }
        } else {
            return move.piece.type.sanIdent
        }
    }
    
    private static func getCheckIdentifier(_ move:Move, position: Position) -> String {
        let validator = MoveValidator(position)
        return validator.isCheckMate(move) ? String(Checkmate) : (validator.isCheck(move) ? String(Check) : "")
    }
    
    private static func getPromotionIdentifier(_ move:Move) -> String {
        guard move.type == .Promotion else { return "" }
        switch move.promoteTo {
        case .queen, .rook, .knight, .bishop:
            return "\(Promotion)\(move.promoteTo.sanIdent)"
        case .pawn, .king:
            return ""
        }
    }
    
    private static func getCaptureIdentifier(_ move:Move, position:Position) -> String {
        return isCapture(move, position: position) ? String(Capture) : ""
    }
    
    private static func getDuplicateIdentifier(_ move: Move, position: Position) -> String {
        guard move.piece.type != .pawn else { return "" }

        let ambiguousPieces = getPiecesForPossibleMoveDuplicate(move, position: position)
        guard !ambiguousPieces.isEmpty else { return "" }

        let shareFile = ambiguousPieces.contains { $0.file == move.piece.file }
        let shareRank = ambiguousPieces.contains { $0.row == move.piece.row }
        if !shareFile {
            return move.piece.field.fileName
        } else if !shareRank {
            return String(move.piece.row)
        } else {
            return "\(move.piece.field.fileName)\(move.piece.row)"
        }
    }
    
    private static func getPiecesForPossibleMoveDuplicate(_ move:Move, position:Position) -> [any ChessFigure] {
        let validator = MoveValidator(position)
        return position.figures.filter { figure in
            guard figure.color == move.piece.color,
                  figure.type == move.piece.type,
                  figure.field != move.piece.field,
                  let candidate = figure.createMove(move.fieldInfo) else { return false }
            return validator.isLegalMove(candidate)
        }
    }
    
    private static func isCapture(_ move:Move, position:Position) -> Bool {
        let pieceAtPosition = position.get(atRow: move.row, atFile: move.file)
        return pieceAtPosition != nil || EnPassantRules.isEnPassant(move, position: position)
    }
    
}
