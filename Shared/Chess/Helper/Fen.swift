import Foundation

public class Fen {
    
    public static let StartSetup = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
    public static func loadStartingPosition() -> Position {
        return FenParser.parse(StartSetup)
    }
    
    public static func loadPosition(_ fen:String) -> Position {
        return FenParser.parse(fen)
    }
    
    public static func create(_ pos:Position) -> String {
        return FenBuilder.create(pos)
    }
}
