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
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (r == row || f==file) {
                    moves.append(createMove(r, f))
                }
            }
        }
        return moves
    }
    
    override func ident() -> String {
        return Rook.Ident
    }
}
