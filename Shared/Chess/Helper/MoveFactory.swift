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
        return Array(input).first?.isUppercase ?? false
    }
    
    public static func create(_ input:any StringProtocol, position:Position) -> Move? {
        let color = position.getColorToMove()
        if isCastlingMove(input) {
            return createCastlingMove(input, color: color, cache: position)
        }
        if isNotAPawnMove(input) {
            return createPieceMove(input, color, position)
        }
        return createPawnMove(input, color: color, cache: position)
    }
    
    private static func createCastlingMove(_ input: any StringProtocol, color: PieceColor, cache: Position) -> Move? {
        let kingRow = getRowOfKing(color)
        let kingFile = getFileOfKing(input)
        let fig = getFigure(targetField: "\(kingFile)\(kingRow)", type: .king, color: color, cache: cache)
        if String(input) == King.CastleKingsideNotation {
            return fig?.createMove("\(kingFile)\(kingRow)", type: .Castle)
        } else {
            return fig?.createMove("\(kingFile)\(kingRow)", type: .Castle)
        }
    }
    
    
    
    private static func createPieceMove(_ input: any StringProtocol, _ color: PieceColor, _ cache: Position) -> Move? {
        
        let cleanedInput = clean(input)
        
        let pieceEndIndex = getEndOfPieceIdentIndex(cleanedInput)!
        
        guard
            let pieceType = getPieceType(cleanedInput[..<pieceEndIndex]),
            let field = getPieceField(cleanedInput)
        else { return nil }
        
        let fig = getPieceFigure(cleanedInput, pieceType: pieceType, color: color, cache: cache)
        
        return fig?.createMove(field)
    }
    
    private static func createPawnMove(_ input: any StringProtocol, color:PieceColor, cache: Position) -> Move? {
        guard let field = getField(input) else { return nil }
        let fig = getFigure(targetField: field, type: .pawn, color: color, cache: cache)
        if isPromotion(input) {
            let promoteTo = getPromotToFigure(input)
            return fig?.createMove(field, type: .Promotion, promoteTo: promoteTo)
        }
        return fig?.createMove(field)
    }
    
    private static func getPieceFigure(_ cleanedInput: any StringProtocol, pieceType: PieceType, color: PieceColor, cache: Position) -> (any ChessFigure)? {
        guard let field = getPieceField(cleanedInput) else { return nil }
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
    
    private static func getFigure(targetField:any StringProtocol, type:PieceType, color:PieceColor, cache:Position) -> (any ChessFigure)? {
        let allFigures = cache.getFigures()
        let figuresOfTypeAndColor = allFigures.filter({ $0.getType() == type && $0.getColor() == color})
        return figuresOfTypeAndColor.first(where: { $0.createMove(targetField) != nil && $0.isMovePossible($0.createMove(targetField)!, position: cache) })
    }
    
    private static func getFigure(_ field: any StringProtocol, withRow:String, type: PieceType, color: PieceColor, cache: Position) -> (any ChessFigure)? {
        
        return cache.getFigures().first(where: { fig in
            guard fig.getType() == type && fig.getColor() == color && fig.getRow() == Int(withRow)! else { return false }
            return fig.isMovePossible(fig.createMove(field)!, position: cache)
        })
    }
    
    private static func getFigure(_ field: any StringProtocol, withFile:String, type: PieceType, color: PieceColor, cache: Position) -> (any ChessFigure)? {
        
        let figures = cache.getFigures().filter({fig in
            return fig.getType() == type && fig.getColor() == color
        })
        return figures.first(where: { fig in
            let fileName = fig.getField().getFileName()
            guard fileName == withFile else { return false }
            
            return fig.isMovePossible(fig.createMove(field)!, position: cache)
        })
    }
    
    private static func getPieceField(_ input:any StringProtocol) -> (any StringProtocol)? {
        let hasFileInfo = hasFileInfo(input)
        let hasRowInfo = hasRowInfo(input)
        let offset = hasFileInfo || hasRowInfo ? 2 : 1
        let fieldStartIndex =  input.index(input.startIndex, offsetBy: offset, limitedBy: input.endIndex)!
        let promotionParts = input[fieldStartIndex...].split(separator: promotionSeparator)
        return promotionParts.first!
    }
    private static func getField(_ input:any StringProtocol) -> (any StringProtocol)? {
        let input = String(input).replacing(checkIndicator, with: "")
        let captureParts = input.split(separator: captureSeparator)
        let promotionParts = captureParts.last?.split(separator: promotionSeparator)
        return promotionParts?.first
    }
    
    private static func isPromotion(_ input:any StringProtocol) -> Bool {
        let captureParts = input.split(separator: captureSeparator)
        let promotionParts = captureParts.last!.split(separator: promotionSeparator)
        return promotionParts.count > 1
    }
    
    private static func getPromotToFigure(_ input:any StringProtocol) -> PieceType {
        let promotionParts = input.split(separator: promotionSeparator)
        return getPieceType(clean(promotionParts.last!)) ?? .queen
    }
    
    private static func isCastlingMove(_ input:any StringProtocol) -> Bool {
        return String(input) == King.CastleQueensideNotation || String(input) == King.CastleKingsideNotation
    }
    
    private static func getEndOfPieceIdentIndex(_ input: any StringProtocol) -> String.Index? {
        return input.index(after: input.startIndex)
    }
    
    private static func getRowOfKing(_ color: PieceColor) -> String {
        return color == .white ? whiteStartingRow : blackStartingRow
    }
    
    private static func getFileOfKing(_ input: any StringProtocol) -> String {
        return String(input) == King.CastleKingsideNotation ? ShortCastleTargetFile : LongCastleTargetFile
    }
    
    private static func hasFileInfo(_ input: any StringProtocol) -> Bool {
        return (input.filter({ $0.isLowercase }) as [Character]).count == 2
    }
    
    private static func hasRowInfo(_ input: any StringProtocol) -> Bool {
        return input.filter({ $0.isNumber }).count == 2
    }
    
    private static func getPiecePositionInfo(_ cleanedInput: any StringProtocol) -> String {
        return String(Array(cleanedInput)[1])
    }
    
    private static func clean(_ input: any StringProtocol) -> String {
        return String(input.filter({ $0 != checkIndicator && $0 != checkmateIndicator && $0 != captureSeparator }))
    }
}

