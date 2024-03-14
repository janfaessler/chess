import Foundation
public class Knight : Figure {
    
    public static let Ident = "N"
    
    public init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .knight, color: color, row: row, file: file, moved: moved)
    }
    
    public override func getPossibleMoves() -> [Move] {
        let row = getRow()
        let file = getFile()
        let moves = [
            CreateMove(row+1, file+2),
            CreateMove(row+1, file-2),
            CreateMove(row-1, file+2),
            CreateMove(row-1, file-2),
            CreateMove(row+2, file+1),
            CreateMove(row+2, file-1),
            CreateMove(row-2, file+1),
            CreateMove(row-2, file-1)
        ]
        return moves.filter({ move in inBoard(move) })
    }
    
    public override func isMovePossible( _ move: Move, cache:BoardCache) -> Bool {
        guard canDo(move: move) else {
            return false
        }
        
        guard let pieceAtTarget = cache.getNextPiece(move) else {
            return true
        }
        
        return super.isCaptureablePiece(move, pieceToCapture: pieceAtTarget);
    }
    
    public override func ident() -> String {
        return Knight.Ident
    }
}
