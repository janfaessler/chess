import Foundation
import os

struct Board: Sendable {
    private static let logger = Log.logger("Board")

    private let cache:[Int:[Int:any ChessFigure]]
    let figures:[any ChessFigure]

    init(_ figures: [any ChessFigure]) {
        let cache = Board.createCacheDict(figures) ?? [:]
        self.cache = cache
        self.figures = cache.flatMap({ $1.values })
    }

    func get(atRow:Int, atFile:Int) -> (any ChessFigure)? {
        return cache[atRow]?[atFile]
    }

    func isEmpty(atRow:Int, atFile:Int) -> Bool {
        return get(atRow: atRow, atFile: atFile) == nil
    }

    func isNotEmpty(atRow:Int, atFile:Int) -> Bool {
        return isEmpty(atRow: atRow, atFile: atFile) == false
    }

    func checkNextIntersection(_ move: Move) -> (any ChessFigure)? {
        let deltaFile = abs(move.piece.file - move.file)
        let deltaRow = abs(move.piece.row - move.row)

        if deltaRow == 0 {
            return checkNextOnRow(from: move.piece.field, to: move.field)
        } else if deltaFile == 0 {
            return checkNextOnFile(from: move.piece.field, to: move.field)
        } else if deltaRow == deltaFile {
            return checkNextOnDiagonal(from: move.piece.field, to: move.field)
        }
        return get(atRow: move.row, atFile: move.file)
    }

    func hash(into hasher: inout Hasher) {
        for fig in figures.sorted(by: { ($0.row, $0.file) > ($1.row, $1.file) }) {
            hasher.combine(fig)
        }
    }

    private func checkNextOnRow(from:Field, to:Field) -> (any ChessFigure)? {
        let direction = from.file < to.file ? 1 : -1
        for f in stride(from: from.file + direction, to: to.file, by: direction) {
            if let piece = get(atRow: from.row, atFile: f) { return piece }
        }
        return get(atRow: to.row, atFile: to.file)
    }

    private func checkNextOnFile(from:Field, to:Field) -> (any ChessFigure)? {
        let direction = from.row < to.row ? 1 : -1
        for r in stride(from: from.row + direction, to: to.row, by: direction) {
            if let piece = get(atRow: r, atFile: from.file) { return piece }
        }
        return get(atRow: to.row, atFile: to.file)
    }

    private func checkNextOnDiagonal(from:Field, to:Field) -> (any ChessFigure)? {
        let rowDir = min(max(to.row - from.row, -1), 1)
        let fileDir = min(max(to.file - from.file, -1), 1)
        let delta = abs(from.file - to.file)
        if delta > 1 {
            for i in 1...delta {
                if let piece = get(atRow: from.row + i * rowDir, atFile: from.file + i * fileDir) { return piece }
            }
        }
        return get(atRow: to.row, atFile: to.file)
    }

    private static func createCacheDict(_ figures: [any ChessFigure]) -> [Int : [Int : any ChessFigure]]? {
        var dict:[Int:[Int:any ChessFigure]] = [:]
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
