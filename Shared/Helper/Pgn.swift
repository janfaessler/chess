import Foundation

public class Pgn {
    
    public static func loadMoves(_ png:String) -> [Move] {
        var result:[Move] = []
        for line in png.split(whereSeparator: \.isNewline) {
            if !line.starts(with: "[") {
                var cache = Fen.loadStartingPosition()
                let moves:[Move?] = line.split{ $0.isWhitespace }.map({ input in
                    let input = input.replacing(". ", with: ".")
                    let dot = input.firstIndex(of: ".")
                    
                    var notation = dot == nil ? input : input[input.index(after: dot!)...]
                    notation = notation.replacing("+", with: "")
                    
                    guard let move = MoveFactory.create(notation, position: cache) else { return nil }
                    cache = updateBoardCache(move, cache: cache, isCapture: notation.contains("x"))
                    return move
                })
                let onlyMoves:[Move] = moves.filter({$0 != nil}) as! [Move]
                result.append(contentsOf: onlyMoves)
            }
        }
        return result

    }
    
    public static func loadPosition(_ moves:[any StringProtocol]) -> Position? {
        var position = Fen.loadStartingPosition()
        for notation in moves {
            guard let move = MoveFactory.create(notation, position: position) else { return nil }
            position = updateBoardCache(move, cache: position, isCapture: notation.contains("x"))
        }
        return position
    }
    
    private static func updateBoardCache(_ move:Move, cache:Position, isCapture:Bool) -> Position{
        var figures:[any ChessFigure] = cache.getFigures()
        let fig = figures.first(where: { $0.equals(move.getPiece())})!
        let capturedPiece = cache.get(atRow: move.getRow(), atFile: move.getFile())
        fig.move(row: move.getRow(), file: move.getFile())
        figures.removeAll(where: {$0.equals(move.getPiece())})
        figures.append(fig)
        if move.getType() == .Castle {
            if move.getFile() == King.CastleQueensidePosition{
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.CastleQueensideStartingFile))})!
                rook.move(row: move.getRow(), file: Rook.CastleQueensideEndFile)
            } else {
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.CastleKingsideStartingFile))})!
                rook.move(row: move.getRow(), file: Rook.CastleKingsideEndFile)
            }
        }
        
        return PositionFactory.create(cache, afterMove: move, figures: figures, capturedPiece: capturedPiece)
    }
}
