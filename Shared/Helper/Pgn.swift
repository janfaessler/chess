import Foundation

public class Pgn {
    
    public static func load(_ png:String) -> [Move] {
        var result:[Move] = []
        for line in png.split(whereSeparator: \.isNewline) {
            if !line.starts(with: "[") {
                var cache = BoardCache.create(Fen.loadStartingPosition().figures)
                let moves:[Move?] = line.split{ $0.isWhitespace }.map({ input in
                    
                    let dot = input.firstIndex(of: ".")
                    
                    let notation = dot == nil ? input : input[input.index(after: dot!)...]
                    guard let move = MoveFactory.create(notation, cache: cache) else { return nil }
                    cache = updateBoardCache(move, cache: cache)
                    return move
                })
                let onlyMoves:[Move] = moves.filter({$0 != nil}) as! [Move]
                result.append(contentsOf: onlyMoves)
            }
        }
        return result

    }
    
    private static func updateBoardCache(_ move:Move, cache:BoardCache) -> BoardCache{
        var figures:[any ChessFigure] = cache.getFigures()
        let fig = figures.first(where: { $0.equals(move.getPiece())})!
        fig.move(row: move.getRow(), file: move.getFile())
        figures.removeAll(where: {$0.equals(move.getPiece())})
        figures.append(fig)
        if move.getType() == .Castle {
            if move.getFile() == King.LongCastlePosition{
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.LongCastleStartingFile))})!
                rook.move(row: move.getRow(), file: Rook.LongCastleEndFile)
            } else {
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.ShortCastleStartingFile))})!
                rook.move(row: move.getRow(), file: Rook.ShortCastleEndFile)
            }
        }
        return BoardCache.create(figures, lastMove: move)
    }
}
