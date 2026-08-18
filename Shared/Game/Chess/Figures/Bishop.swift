import Foundation

class Bishop : Figure {

    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .bishop, color: color, row: row, file: file, moved: moved)
    }

    override func getPossibleMoves() -> [Move] {
        return movesAlongRays([(1, 1), (1, -1), (-1, 1), (-1, -1)])
    }
}
