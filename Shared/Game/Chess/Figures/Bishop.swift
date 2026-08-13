import Foundation

class Bishop : Figure {
    
    static let Ident = "B"
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .bishop, color: color, row: row, file: file, moved: moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        var moves:[Move] = []
        for r in 1...8 {
            for f in 1...8 {
                if !(getRow() == r && getFile() == f) && (getRow()-r == getFile()-f || getRow()+getFile() == r+f) {
                    moves.append(createMove(r, f))
                }
            }
        }
        return moves
    }
    
    override func ident() -> String {
        return Bishop.Ident
    }
}
