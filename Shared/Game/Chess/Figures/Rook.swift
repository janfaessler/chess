import Foundation

class Rook : Figure {
    
    static let Ident = "R"
    static let CastleQueensideStartingFile = 1
    static let CastleQueensideEndFile = 4
    static let CastleKingsideStartingFile = 8
    static let CastleKingsideEndFile = 6
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .rook, color: color, row: row, file: file, moved:moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        return movesAlongRays([(1, 0), (-1, 0), (0, 1), (0, -1)])
    }
    
    override func ident() -> String {
        return Rook.Ident
    }
}
