import Foundation

public class LanParser {
    
    private init() {}
    
    public static func parse(lan: String, position: Position) -> Move? {
        
        let startSquareIndex = lan.index(lan.startIndex, offsetBy: 2)
        let startSquareString = String(lan[..<startSquareIndex])
        guard let start = Field(startSquareString) else { return nil }
        
        let endSquareIndex = lan.index(startSquareIndex, offsetBy: 2)
        let endSquareString = String(lan[startSquareIndex..<endSquareIndex])
        
        var promotedPiece: PieceType?
        
        if lan.count == 5 {
            promotedPiece = parcePieceType(Array(lan).last!)
        }
        guard let figure = position.get(atRow: start.row, atFile:start.file) else { return nil}
        
        
        guard var move = figure.createMove(endSquareString) else { return nil }
        guard figure.isMovePossible(move, position: position) else { return nil }
        
        if promotedPiece != nil {
            move.promoteTo = promotedPiece!
        }
        return move
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
}
