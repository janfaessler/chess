import Foundation

class Queen : Figure {
    
    static let Ident = "Q"
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .queen, color: color, row: row, file: file, moved: moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(row == r && file == f) && (r == row || f == file || row-r == file-f || row+file == r+f) {
                    moves.append(createMove(r, f))
                }
            }
        }
        return moves
    }
    
    override func ident() -> String {
        return Queen.Ident
    }
}
