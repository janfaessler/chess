import Foundation
import os

struct Board: BoardQuery, Sendable {
    private static let logger = Log.logger("Board")

    private let grid:[Int:[Int:any ChessPiece]]
    let figures:[any ChessPiece]

    init(_ figures: [any ChessPiece]) {
        let grid = Board.createCacheDict(figures) ?? [:]
        self.grid = grid
        self.figures = grid.flatMap({ $1.values })
    }

    func get(atRow:Int, atFile:Int) -> (any ChessPiece)? {
        return grid[atRow]?[atFile]
    }

    func isEmpty(atRow:Int, atFile:Int) -> Bool {
        return get(atRow: atRow, atFile: atFile) == nil
    }

    func isNotEmpty(atRow:Int, atFile:Int) -> Bool {
        return isEmpty(atRow: atRow, atFile: atFile) == false
    }

    func checkNextIntersection(_ move: Move) -> (any ChessPiece)? {
        PathChecker(self).firstPieceOnPath(from: move.piece.square, to: move.square)
    }

    func hash(into hasher: inout Hasher) {
        for fig in figures.sorted(by: { ($0.row, $0.file) > ($1.row, $1.file) }) {
            hasher.combine(fig)
        }
    }

    private static func createCacheDict(_ figures: [any ChessPiece]) -> [Int : [Int : any ChessPiece]]? {
        var dict:[Int:[Int:any ChessPiece]] = [:]
        for figure in figures {
            if dict[figure.row] == nil {
                dict[figure.row] = [:]
            }
            guard dict[figure.row]?[figure.file] == nil else {
                Board.logger.error("could not set \(figure.info()) because field is occupied by \(dict[figure.row]?[figure.file]?.info() ?? "")")
                return nil
            }
            dict[figure.row]![figure.file] = figure
        }
        return dict
    }
}
