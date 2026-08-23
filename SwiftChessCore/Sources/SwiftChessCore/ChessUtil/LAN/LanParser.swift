import Foundation

public class LanParser {

    private init() {}

    public static func parse(lan: String, position: Position) -> Move? {
        guard lan.count >= 4 else { return nil }

        let startSquareIndex = lan.index(lan.startIndex, offsetBy: 2)
        let startSquareString = String(lan[..<startSquareIndex])
        guard let start = Square(startSquareString) else { return nil }
        
        let endSquareIndex = lan.index(startSquareIndex, offsetBy: 2)
        let endSquareString = String(lan[startSquareIndex..<endSquareIndex])
        
        guard let figure = position.get(atRow: start.row, atFile:start.file) else { return nil}
        
        guard let move = figure.createMove(endSquareString) else { return nil }
        guard figure.isMovePossible(move, position: position) else { return nil }
        
        if lan.count == 5, let promotedPiece = lan.last.flatMap(PieceType.init(fenChar:)) {
            return Move(move, promoteTo: promotedPiece)
        }
        return move
    }
}
