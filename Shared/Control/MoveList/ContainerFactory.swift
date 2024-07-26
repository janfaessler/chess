import Foundation

public class ContainerFactory {

    public static func create(_ game:PgnGame) -> [RowContainer] {
        return getRowContainers(game.moves, startingColor: .white, startingMoveNumber:1)
    }
    
    private static func getRowContainers(_ moves:[PgnMove], startingColor:PieceColor, startingMoveNumber:Int) -> [RowContainer] {
        var containers:[RowContainer] = []
        var color = startingColor
        var moveNumber = startingMoveNumber
        for move in moves {
            let moveContainer = MoveContainer(move: move.move, color: color, note: move.comment)
            
            for variation in move.variations {
                guard let variationName = variation.first?.move else { continue }
                moveContainer.variations[variationName] = getRowContainers(variation, startingColor: color, startingMoveNumber: moveNumber)
            }
            
            if color == .white {
                containers += [RowContainer(moveNumber: moveNumber, white: moveContainer)]
            } else {
                if containers.count == 0 {
                    containers += [RowContainer(moveNumber: moveNumber)]
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
}
