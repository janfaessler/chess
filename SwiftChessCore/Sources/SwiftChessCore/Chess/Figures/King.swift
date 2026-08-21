import Foundation

class King : Figure, @unchecked Sendable {
    
    static let CastleQueensidePosition = 3
    static let CastleKingsidePosition = 7
    
    init(color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        super.init(type: .king, color: color, row: row, file: file, moved: moved)
    }
    
    override func getPossibleMoves() -> [Move] {
        let row = row
        let file = file
        var moves = [
            createMove(row+1, file+1),
            createMove(row, file+1),
            createMove(row+1, file),
            createMove(row-1, file-1),
            createMove(row, file-1),
            createMove(row-1, file),
            createMove(row-1, file+1),
            createMove(row+1, file-1)
        ]
        if (!hasMoved()) {
            moves.append(contentsOf: [
                createMove(row, King.CastleQueensidePosition, MoveType.Castle),
                createMove(row, King.CastleKingsidePosition, MoveType.Castle)
            ])
        }
        return moves.filter({ move in inBoard(move) })
    }
    
    override func isMovePossible( _ move: Move, position:Position) -> Bool {
        if CastlingRules.isCastlingMove(move) {
            return CastlingRules.canCastle(move, position: position)
        }
        
        return super.isMovePossible(move, position: position)
    }
    
    override func createMove(_ filename: any StringProtocol) -> Move? {
        let possibleMoves = getPossibleMoves()
        return possibleMoves.first(where: {$0.fieldInfo == filename})
    }
}
