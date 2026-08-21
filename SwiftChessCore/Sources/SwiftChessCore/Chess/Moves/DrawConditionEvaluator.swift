import Foundation

struct DrawConditionEvaluator {

    private static let halfmoveLimit = 100
    private static let threefoldRepetitionThreshold = 3

    static func isInsufficientMaterial(figures: [any ChessFigure]) -> Bool {
        return onlyKingsLeft(figures)
            || onlyOneMinorPieceLeft(figures, type: .knight)
            || onlyOneMinorPieceLeft(figures, type: .bishop)
            || onlySameColorBishopsLeft(figures)
    }

    static func isThreefoldRepetition(positionCount: [Int: Int], currentHash: Int) -> Bool {
        return (positionCount[currentHash] ?? 0) >= threefoldRepetitionThreshold
    }

    static func has50MoveRuleTriggered(halfmoveClock: Int) -> Bool {
        return halfmoveClock >= halfmoveLimit
    }

    private static func onlyKingsLeft(_ figures: [any ChessFigure]) -> Bool {
        return figures.count == 2 && figures.allSatisfy({ $0.type == .king })
    }

    private static func onlyOneMinorPieceLeft(_ figures: [any ChessFigure], type: PieceType) -> Bool {
        return figures.count == 3 && figures.filter({ $0.type == type }).count == 1
    }

    private static func onlySameColorBishopsLeft(_ figures: [any ChessFigure]) -> Bool {
        guard figures.count == 4 else { return false }
        let bishops = figures.filter({ $0.type == .bishop })
        guard
            bishops.count == 2,
            Set(bishops.map({ $0.color })).count == 2
        else { return false }
        let squareColors = bishops.map({ ($0.row + $0.file) % 2 })
        return Set(squareColors).count == 1
    }
}
