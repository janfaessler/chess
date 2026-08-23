import Foundation

enum SlidingMoves {
    static func along(rays: [(row: Int, file: Int)], piece: any ChessPiece) -> [Move] {
        var moves: [Move] = []
        for direction in rays {
            var r = piece.row + direction.row
            var f = piece.file + direction.file
            while 1...8 ~= r && 1...8 ~= f {
                moves.append(piece.createMove(r, f, .normal))
                r += direction.row
                f += direction.file
            }
        }
        return moves
    }
}
