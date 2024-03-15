import Foundation

public class MoveFactory {
    
    private static let captureSeparator:Character = "x"
    private static let promotionSeparator:Character = "="
    private static let checkIndicator:Character = "+"
    private static let checkmateIndicator:Character = "#"
    private static let whiteStartingRow = "1"
    private static let blackStartingRow = "8"
    private static let ShortCastleTargetFile = "g"
    private static let LongCastleTargetFile = "c"
    
    private static func isNotAPawnMove(_ input: any StringProtocol) -> Bool {
        return Array(input).first!.isUppercase
    }
    
    public static func create(_ input:String, cache:BoardCache) -> Move? {
        let color = cache.getLastMove()?.piece.getColor() == PieceColor.white ? PieceColor.black : PieceColor.white
        if isCastlingMove(input) {
            return createCastlingMove(input, color: color, cache: cache)
        }
        if isNotAPawnMove(input) {
            return createPieceMove(input, color, cache)
        }
        return createPawnMove(input, color: color, cache: cache)
    }
    
    private static func createCastlingMove(_ input: String, color: PieceColor, cache: BoardCache) -> Move? {
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
        
        let cleanedInput = input.filter({ $0 != checkIndicator && $0 != checkmateIndicator && $0 != captureSeparator })
        
        let pieceEndIndex = getEndOfPieceIdentIndex(cleanedInput)!
        guard let pieceType = getPieceType(cleanedInput[..<pieceEndIndex]) else { return nil }
        
        let field = getPieceField(cleanedInput)
        
        let fig = getPieceFigure(cleanedInput, pieceType: pieceType, color: color, cache: cache)
        
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
    
    private static func getPieceFigure(_ cleanedInput: String, pieceType: PieceType, color: PieceColor, cache: BoardCache) -> ChessFigure? {
        let field = getPieceField(cleanedInput)
        if hasRowInfo(cleanedInput){
            let rowInfo = getPiecePositionInfo(cleanedInput)
            return getFigure(field, withRow: rowInfo, type: pieceType, color: color, cache: cache)
        } else if hasFileInfo(cleanedInput) {
            let fileInfo = getPiecePositionInfo(cleanedInput)
            return getFigure(field, withFile: fileInfo, type: pieceType, color: color, cache: cache)
        } else {
            return getFigure(targetField: field, type: pieceType, color: color, cache: cache)
        }
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
    
    private static func getFigure(_ field: any StringProtocol, withRow:String, type: PieceType, color: PieceColor, cache: BoardCache) -> ChessFigure? {
        
        return cache.getFigures().first(where: { fig in
            guard fig.getType() == type && fig.getColor() == color && fig.getRow() == Int(withRow)! else { return false }
            return fig.isMovePossible(fig.createMove(field)!, cache: cache)
        })
    }
    
    private static func getFigure(_ field: any StringProtocol, withFile:String, type: PieceType, color: PieceColor, cache: BoardCache) -> ChessFigure? {
        
        let figures = cache.getFigures().filter({fig in
            return fig.getType() == type && fig.getColor() == color
        })
        return figures.first(where: { fig in
            let fileName = fig.getField().getFileName()
            guard fileName == withFile else { return false }
            
            return fig.isMovePossible(fig.createMove(field)!, cache: cache)
        })
    }
    
    private static func getPieceField(_ input:any StringProtocol) -> any StringProtocol {
        let hasFileInfo = hasFileInfo(input)
        let hasRowInfo = hasRowInfo(input)
        let offset = hasFileInfo || hasRowInfo ? 2 : 1
        let fieldStartIndex =  input.index(input.startIndex, offsetBy: offset, limitedBy: input.endIndex)!
        let promotionParts = input[fieldStartIndex...].split(separator: promotionSeparator)
        return promotionParts.first!
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
        return input.index(after: input.startIndex)
    }
    
    private static func getRowOfKing(_ color: PieceColor) -> String {
        return color == .white ? whiteStartingRow : blackStartingRow
    }
    
    private static func getFileOfKing(_ input: String) -> String {
        return input == King.ShortCastleNotation ? ShortCastleTargetFile : LongCastleTargetFile
    }
    
    private static func hasFileInfo(_ input: any StringProtocol) -> Bool {
        return (input.filter({ $0.isLowercase }) as [Character]).count == 2
    }
    
    private static func hasRowInfo(_ input: any StringProtocol) -> Bool {
        return input.filter({ $0.isNumber }).count == 2
    }
    
    private static func getPiecePositionInfo(_ cleanedInput: String) -> String {
        return String(Array(cleanedInput)[1])
    }
}
