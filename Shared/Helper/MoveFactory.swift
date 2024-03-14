import Foundation

public class MoveFactory {
    
    private static let captureSeparator:String = "x"
    private static let promotionSeparator:String = "="
    private static let whiteStartingRow:String = "1"
    private static let blackStartingRow:String = "8"
    private static let ShortCastleTargetFile:String = "g"
    private static let LongCastleTargetFile:String = "c"
        
    private static func isNotAPawnMove(_ input: any StringProtocol) -> Bool {
        return Array(input).first!.isUppercase
    }
    
    public static func create(_ input:String, cache:BoardCache) -> Move? {
        let color = cache.getLastMove()?.piece.getColor() == PieceColor.white ? PieceColor.black : PieceColor.white
        if isCastlingMove(input) {
            return createCastlingMove(color, input, cache)
        }
        if isNotAPawnMove(input) {
            return createPieceMove(input, color, cache)
        }
        return createPawnMove(input, color: color, cache: cache)
    }
    
    private static func createCastlingMove(_ color: PieceColor, _ input: String, _ cache: BoardCache) -> Move? {
        let kingRow = getRowOfKing(color)
        let kingFile = getFileOfKing(input)
        let fig = getFigure(targetField: "\(kingFile)\(kingRow)", type: .king, color: color, cache: cache)
        if input == King.ShortCastleNotation {
            return fig?.createMove("\(kingFile)\(kingRow)", type: .Castle)
        } else {
            return fig?.createMove("\(kingFile)\(kingRow)", type: .Castle)
        }
    }
    
    private static func createPieceMove(_ input: String, _ color: PieceColor, _ cache: BoardCache) -> Move? {
        let pieceEndIndex = getEndOfPieceIdentIndex(input)!
        let pieceType = getPieceType(input[..<pieceEndIndex])
        let field = getField(input[pieceEndIndex...])
        let fig:ChessFigure? = getFigure(targetField: field, type: pieceType!, color: color, cache: cache)
        return fig?.createMove(field)
    }
    
    private static func createPawnMove(_ input: String, color:PieceColor, cache: BoardCache) -> Move? {
        let field = getField(input)
        let fig:ChessFigure? = getFigure(targetField: field, type: .pawn, color: color, cache: cache)
        if isPromotion(input) {
            return fig?.createMove(field, type: .Promotion)
        }
        return fig?.createMove(field)
    }
    
    private static func getPieceType(_ char:any StringProtocol) -> PieceType? {
        switch String(char) {
        case Bishop.Ident: return .bishop
        case Knight.Ident: return .knight
        case Queen.Ident: return .queen
        case Rook.Ident: return .rook
        case King.Ident: return .king
        default: return nil
        }
    }
    
    private static func getFigure(targetField:any StringProtocol, type:PieceType, color:PieceColor, cache:BoardCache) -> ChessFigure? {
        let allFigures = cache.getFigures()
        let figuresOfTypeAndColor = allFigures.filter({ $0.getType() == type && $0.getColor() == color})
        return figuresOfTypeAndColor.first(where: { $0.createMove(targetField) != nil && $0.isMovePossible($0.createMove(targetField)!, cache: cache) })
    }
    
    private static func getField(_ input:any StringProtocol) -> any StringProtocol {
        let captureParts = input.split(separator: captureSeparator)
        let promotionParts = captureParts.last!.split(separator: promotionSeparator)
        return promotionParts.first!
    }
    
    private static func isPromotion(_ input:String) -> Bool {
        let captureParts = input.split(separator: captureSeparator)
        let promotionParts = captureParts.last!.split(separator: promotionSeparator)
        return promotionParts.count > 1
    }
    
    private static func isCastlingMove(_ input: String) -> Bool {
        return input == King.LongCastleNotation || input == King.ShortCastleNotation
    }
    
    private static func getEndOfPieceIdentIndex(_ input: String) -> String.Index? {
        return input.firstIndex(where: {$0.isLowercase})
    }
    
    private static func getRowOfKing(_ color: PieceColor) -> String {
        return color == .white ? whiteStartingRow : blackStartingRow
    }
    
    private static func getFileOfKing(_ input: String) -> String {
        return input == King.ShortCastleNotation ? ShortCastleTargetFile : LongCastleTargetFile
    }
}
