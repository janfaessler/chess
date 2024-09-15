import Foundation

public class StructureFactory {

    public static func create(_ game:PgnGame) -> MoveStructure{
        let rows = getRowContainers(game.moves, startingColor: .white, startingMoveNumber:1)
        let cache = createVariationCache(rows.all)
        return MoveStructure(line: rows, parrentMoves: cache)
    }
    
    private static func getRowContainers(_ moves:[PgnMove], startingColor:PieceColor, startingMoveNumber:Int) -> LineModel {
        var containers:[MovePairModel] = []
        var color = startingColor
        var moveNumber = startingMoveNumber
        for move in moves {
            let moveContainer = MoveModel(move: move.move, color: color, note: move.comment)
            
            for variation in move.variations {
                guard let variationName = variation.first?.move else { continue }
                moveContainer.addVariation(variationName, variation: getRowContainers(variation, startingColor: color, startingMoveNumber: moveNumber))
            }
            
            if color == .white {
                containers += [MovePairModel.create(moveContainer, moveNumber: moveNumber)]
            } else {
                if containers.count == 0 {
                    containers += [MovePairModel.create(moveNumber: moveNumber)]
                }
                let lastContainer = containers[containers.index(before: containers.endIndex)]
                lastContainer.black = moveContainer
                moveNumber += 1
            }
            color = flipColor(color)
        }
        return LineModel(containers)
    }
    
    private static func flipColor(_ color: PieceColor) -> PieceColor {
        return color == .white ? .black : .white
    }
    
    private static func createVariationCache(_ rows:[MovePairModel]) -> [UUID:MoveModel]  {
        var cache:[UUID:MoveModel] = [:]
        for row in rows {
            if row.hasVariations(.white) {
                createCacheForVariations(row.white!, cache: &cache)
            }
            if row.hasVariations(.black) {
                createCacheForVariations(row.black!, cache: &cache)
            }
        }
        return cache
    }
    
    private static func createCacheForVariations(_ move: MoveModel, cache:inout [UUID:MoveModel]) {
        for name in  move.getVariations() {
            guard let line = move.getVariation(name) else { continue }
            for row in line.all  {
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
