import Foundation
class Knight : Figure {
    
    static let Ident = "N"
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .knight, color: color, row: row, file: file, moved: moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        let row = row
        let file = file
        let moves = [
            createMove(row+1, file+2),
            createMove(row+1, file-2),
            createMove(row-1, file+2),
            createMove(row-1, file-2),
            createMove(row+2, file+1),
            createMove(row+2, file-1),
            createMove(row-2, file+1),
            createMove(row-2, file-1)
        ]
        return moves.filter({ move in inBoard(move) })
    }
    
    override func isMovePossible( _ move: Move, position:Position) -> Bool {
        guard canDo(move: move) else {
            return false
        }
        
        guard let pieceAtTarget = position.getNextPiece(move) else {
            return true
        }
        
        return super.isCaptureablePiece(move, pieceToCapture: pieceAtTarget);
    }
    
    override func ident() -> String {
        return Knight.Ident
    }
}
