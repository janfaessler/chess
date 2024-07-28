import Foundation

public class StructureFactory {

    public static func create(_ game:PgnGame) -> MoveStructure{
        let rows = getRowContainers(game.moves, startingColor: .white, startingMoveNumber:1)
        let cache = createVariationCache(rows)
        return MoveStructure(rows: rows, parrentMoves: cache)
    }
    
    private static func getRowContainers(_ moves:[PgnMove], startingColor:PieceColor, startingMoveNumber:Int) -> [MovePairModel] {
        var containers:[MovePairModel] = []
        var color = startingColor
        var moveNumber = startingMoveNumber
        for move in moves {
            let moveContainer = MoveModel(move: move.move, color: color, note: move.comment)
            
            for variation in move.variations {
                guard let variationName = variation.first?.move else { continue }
                moveContainer.variations[variationName] = getRowContainers(variation, startingColor: color, startingMoveNumber: moveNumber)
            }
            
            if color == .white {
                containers += [MovePairModel(moveNumber: moveNumber, white: moveContainer)]
            } else {
                if containers.count == 0 {
                    containers += [MovePairModel(moveNumber: moveNumber)]
                }
                let lastContainer = containers[containers.index(before: containers.endIndex)]
                lastContainer.black = moveContainer
                moveNumber += 1
            }
            color = flipColor(color)
        }
        return containers
    }
    
    private static func flipColor(_ color: PieceColor) -> PieceColor {
        return color == .white ? .black : .white
    }
    
    private static func createVariationCache(_ rows:[MovePairModel]) -> [UUID:MoveModel]  {
        var cache:[UUID:MoveModel] = [:]
        for row in rows {
            if row.hasWhiteVariations() {
                createCacheForVariations(row.white!, cache: &cache)
            }
            if row.hasBlackVariations() {
                createCacheForVariations(row.black!, cache: &cache)
            }
        }
        return cache
    }
    
    private static func createCacheForVariations(_ move: MoveModel, cache:inout [UUID:MoveModel]) {
        let variations = move.variations
        for name in variations.keys {
            guard let variation = variations[name] else { continue }
            for row in variation {
                createCacheForVariations(row, to: move, cache: &cache)
            }
        }
    }
    
    private static func createCacheForVariations(_ row: MovePairModel, to:MoveModel,  cache:inout [UUID:MoveModel]) {
        if row.hasWhiteMoved() {
            guard let move = row.white else { return }
            cache[move.id] = to
            createCacheForVariations(move, cache: &cache)
        }
        if row.hasBlackMoved() {
            guard let move = row.black else { return }
            cache[move.id] = to
            createCacheForVariations(move, cache: &cache)
        }
    }
}
