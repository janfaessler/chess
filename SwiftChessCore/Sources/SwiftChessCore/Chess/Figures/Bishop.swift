import Foundation

class Bishop : Figure, @unchecked Sendable {

    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .bishop, color: color, row: row, file: file, moved: moved)
    }

    override func getPossibleMoves() -> [Move] {
        SlidingMoves.along(rays: [(1, 1), (1, -1), (-1, 1), (-1, -1)], piece: self)
    }
}
