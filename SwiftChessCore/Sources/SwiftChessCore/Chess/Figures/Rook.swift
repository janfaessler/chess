import Foundation

class Rook : Piece, @unchecked Sendable {
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .rook, color: color, row: row, file: file, moved:moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        SlidingMoves.along(rays: [(1, 0), (-1, 0), (0, 1), (0, -1)], piece: self)
    }
}
