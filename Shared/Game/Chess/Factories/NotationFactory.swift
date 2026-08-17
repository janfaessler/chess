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
            return move.piece.ident()
        }
    }
    
    private static func getCheckIdentifier(_ move:Move, position: Position) -> String {
        let validator = MoveValidator(position)
        return validator.isCheckMate(move) ? String(Checkmate) : (validator.isCheck(move) ? String(Check) : "")
    }
    
    private static func getPromotionIdentifier(_ move:Move) -> String {
        guard move.type == .Promotion else { return "" }
        switch move.promoteTo  {
        case PieceType.queen:
            return "=\(Queen.Ident)"
        case PieceType.rook:
            return "=\(Rook.Ident)"
        case PieceType.knight:
            return "=\(Knight.Ident)"
        case PieceType.bishop:
            return "=\(Bishop.Ident)"
        case .pawn:
            return ""
        case .king:
            return ""
        }
    }
    
    private static func getCaptureIdentifier(_ move:Move, position:Position) -> String {
        return isCapture(move, position: position) ? String(Capture) : ""
    }
    
    private static func getDuplicateIdentifier(_ move: Move, position: Position) -> String {
        var duplicateIdentifier = ""
        let figureThatCanDoTheSameMove = getPieceForPossibleMoveDuplicate(move, position: position)
        let pieceIsOnSameFile = move.piece.file == figureThatCanDoTheSameMove?.file
        if pieceIsOnSameFile {
            if move.piece.type == .pawn {
                duplicateIdentifier = move.piece.field.fileName
            } else {
                duplicateIdentifier = String(move.piece.row)
            }
        }
        let pieceIsOnSameRow = move.piece.row == figureThatCanDoTheSameMove?.row
        if pieceIsOnSameRow {
            duplicateIdentifier = move.piece.field.fileName
        }
        return duplicateIdentifier
    }
    
    private static func getPieceForPossibleMoveDuplicate(_ move:Move, position:Position) -> (any ChessFigure)? {
        let validator = MoveValidator(position)
        return position.figures.first { figure in
            guard figure.color == move.piece.color,
                  figure.type == move.piece.type,
                  figure.field != move.piece.field,
                  let candidate = figure.createMove(move.fieldInfo) else { return false }
            return validator.isLegalMove(candidate)
        }
    }
    
    private static func isCapture(_ move:Move, position:Position) -> Bool {
        let pieceAtPosition = position.get(atRow: move.row, atFile: move.file)
        return pieceAtPosition != nil || position.isEnPassant(move)
    }
    
}
