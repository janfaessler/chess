import Foundation

public class Fen {
    
    static let StartSetup = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
    public static func loadStartingPosition() -> Position {
        return loadPosition(StartSetup)
    }
    
    public static func loadPosition(_ fen:String) -> Position {
        let parts = fen.split(separator: " ").map({String($0)})
        return Position(
            figures: getFigures(parts[0]),
            colorToMove: getNextMove(parts[1]),
            whiteShortCastle: canWhiteCastleShort(parts[2]),
            whiteLongCastle: canWhiteCastleLong(parts[2]),
            blackShortCastle: canBlackCastleShort(parts[2]),
            blackLongCastle: canBlackCastleLong(parts[2]),
            enPassantTarget: getEnPassantTarget(parts[3]),
            moveCountSinceLastChange: parseInt(parts[4]),
            moveCount: parseInt(parts[5]))
    }
    
    private static func getFigures(_ position: String) -> [Figure] {
        var figures:[Figure] = []
        var row = 8
        for rowPart in position.split(separator: "/") {
            let figuresLine = parseLine(rowPart, rowNumber: row)
            figures.append(contentsOf: figuresLine)
            row -= 1
        }
        return figures
    }
    
    private static func canWhiteCastleShort(_ str:String) -> Bool {
        return str.contains(where: { String($0) == King.Ident})
    }
    
    private static func canWhiteCastleLong(_ str:String) -> Bool {
        return str.contains(where: { String($0) == Queen.Ident})
    }
    
    private static func canBlackCastleShort(_ str:String) -> Bool {
        return str.contains(where: { String($0) == King.Ident.lowercased()})
    }
    
    private static func canBlackCastleLong(_ str:String) -> Bool {
        return str.contains(where: { String($0) == Queen.Ident.lowercased()})
    }
    
    private static func getEnPassantTarget(_ str:String) -> Field? {
        return Field(str)
    }
    
    private static func getNextMove(_ nextMove:String) -> PieceColor{
        return nextMove.lowercased() == "w" ? .white : .black
    }
    
    private static func parseLine(_ rowPart: String.SubSequence,  rowNumber: Int) -> [Figure]{
        var figures:[Figure] = []
        var file = 1
        for part in Array(rowPart) {
            let digit = Int("\(part)")
            if (digit == nil) {
                guard let fig = parsePiece(part, rowNumber: rowNumber, fileNumber: file) else {
                    break
                }
                figures.append(fig)
                file += 1
            } else {
                file += digit!
            }
        }
        
        return figures
    }
    
    private static func parsePiece(_ str: Character, rowNumber:Int, fileNumber:Int) -> Figure? {
        let pieceType = parcePieceType(str);
        let pieceColor = parseColor(str);
        return createFigure(pieceType, pieceColor, rowNumber, fileNumber)
    }
    
    private static func createFigure(_ pieceType: PieceType?, _ pieceColor: PieceColor, _ rowNumber: Int, _ fileNumber: Int) -> Figure? {
        switch (pieceType) {
            case .pawn:
                return Pawn(color: pieceColor, row: rowNumber, file: fileNumber)
            case .bishop:
                return Bishop(color: pieceColor, row: rowNumber, file: fileNumber)
            case .knight:
                return Knight(color: pieceColor, row: rowNumber, file: fileNumber)
            case .rook:
                return Rook(color: pieceColor, row: rowNumber, file: fileNumber)
            case .queen:
                return Queen(color: pieceColor, row: rowNumber, file: fileNumber)
            case .king:
                return King(color: pieceColor, row: rowNumber, file: fileNumber)
            case .none:
                return nil
        }
    }
    
    private static func parcePieceType(_ str:Character) -> PieceType? {
        switch str.uppercased() {
        case Bishop.Ident: return .bishop
        case Knight.Ident: return .knight
        case Rook.Ident: return .rook
        case Queen.Ident: return .queen
        case King.Ident: return .king
        default: return .pawn
        }
    }
    
    private static func parseColor(_ str:Character) -> PieceColor {
        return str.isLowercase ? .black : .white
    }
    
    private static func parseInt(_ str: String) -> Int {
        return Int(str) ?? 0
    }
}
