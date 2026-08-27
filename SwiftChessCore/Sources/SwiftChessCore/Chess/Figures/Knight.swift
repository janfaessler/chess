import Foundation
class Knight : Piece, @unchecked Sendable {

    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .knight, color: color, row: row, file: file, moved: moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        let row = row
        let file = file
        var moves: [Move] = []
        moves.reserveCapacity(8)
        if let m = createMove(row+1, file+2) { moves.append(m) }
        if let m = createMove(row+1, file-2) { moves.append(m) }
        if let m = createMove(row-1, file+2) { moves.append(m) }
        if let m = createMove(row-1, file-2) { moves.append(m) }
        if let m = createMove(row+2, file+1) { moves.append(m) }
        if let m = createMove(row+2, file-1) { moves.append(m) }
        if let m = createMove(row-2, file+1) { moves.append(m) }
        if let m = createMove(row-2, file-1) { moves.append(m) }
        return moves
    }
    
    override func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool {
        guard canDo(move: move) else { return false }
        guard let pieceAtTarget = board.checkNextIntersection(move) else { return true }
        return super.isCaptureablePiece(move, pieceToCapture: pieceAtTarget)
    }
}
