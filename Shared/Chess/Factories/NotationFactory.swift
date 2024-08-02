import Foundation

public class NotationFactory {
    
    public static let LongCastle = "O-O-O"
    public static let ShortCastle = "O-O"
    public static let Capture:Character = "x"
    public static let Promotion:Character = "="
    public static let Check:Character = "+"
    public static let Checkmate:Character = "#"
    
    public static func generate(_ move:Move, position:Position) -> String {
        guard !move.isCastling() else { 
            return getCastlingNotation(move, position:position)
        }
        let checkIdentifier = getCheckIdentifier(move, position: position)

        let piece = getPieceIdentifier(move, position: position)
        let duplicateIdentifier = getDuplicateIdentifier(move, position: position)
        let captureIdentifier = getCaptureIdentifier(move, position: position)
        let field = move.getFieldInfo()
        let promotionIdentifier = getPromotionIdentifier(move)
        return "\(piece)\(duplicateIdentifier)\(captureIdentifier)\(field)\(promotionIdentifier)\(checkIdentifier)"
    }
    
    private static func getCastlingNotation(_ move:Move, position:Position) -> String {
        if position.isLongCastling(move) {
            return LongCastle
        } else if position.isShortCastling(move) {
            return ShortCastle
        }
        return ""
    }
    
    private static func getPieceIdentifier(_ move:Move, position:Position) -> String {
        if move.piece.getType() == .pawn {
            if isCapture(move, position: position) {
                return move.piece.getField().getFileName()
            } else {
                return ""
            }
        } else {
            return move.piece.ident()
        }
    }
    
    private static func getCheckIdentifier(_ move:Move, position: Position) -> String {
        return position.isCheckMate(move) ? String(Checkmate) : (position.isCheck(move) ? String(Check) : "")
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
        let pieceIsOnSameFile = move.getPiece().getFile() == figureThatCanDoTheSameMove?.getFile()
        if pieceIsOnSameFile {
            if move.piece.getType() == .pawn {
                duplicateIdentifier = move.piece.getField().getFileName()
            } else {
                duplicateIdentifier = String(move.getPiece().getRow())
            }
        }
        let pieceIsOnSameRow = move.getPiece().getRow() == figureThatCanDoTheSameMove?.getRow()
        if pieceIsOnSameRow {
            duplicateIdentifier = move.getPiece().getField().getFileName()
        }
        return duplicateIdentifier
    }
    
    private static func getPieceForPossibleMoveDuplicate(_ move:Move, position:Position) -> (any ChessFigure)? {
        position.getFigures().first {
            $0.getColor() == move.piece.getColor()
            && $0.getType() == move.getPiece().getType()
            && $0.getField() != move.piece.getField()
            && $0.createMove(move.getFieldInfo()) != nil
            && position.IsMoveLegalMoveOnTheBoard($0.createMove(move.getFieldInfo())!)
        }
    }
    
    private static func isCapture(_ move:Move, position:Position) -> Bool {
        let pieceAtPosition = position.get(atRow: move.getRow(), atFile: move.getFile())
        return pieceAtPosition != nil || position.isEnPassant(move)
    }
    
}
