import Foundation

class Queen : Figure {
    
    static let Ident = "Q"
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .queen, color: color, row: row, file: file, moved: moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        return movesAlongRays([(1, 0), (-1, 0), (0, 1), (0, -1),
                               (1, 1), (1, -1), (-1, 1), (-1, -1)])
    }
    
    override func ident() -> String {
        return Queen.Ident
    }
}
