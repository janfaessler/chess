import Foundation

struct PathChecker {
    private let board: Board

    init(_ board: Board) {
        self.board = board
    }

    func firstPieceOnPath(from: Field, to: Field) -> (any ChessFigure)? {
        let deltaFile = abs(from.file - to.file)
        let deltaRow = abs(from.row - to.row)
        if deltaRow == 0 { return checkRow(from: from, to: to) }
        if deltaFile == 0 { return checkFile(from: from, to: to) }
        if deltaRow == deltaFile { return checkDiagonal(from: from, to: to) }
        return board.get(atRow: to.row, atFile: to.file)
    }

    private func checkRow(from: Field, to: Field) -> (any ChessFigure)? {
        let direction = from.file < to.file ? 1 : -1
        for f in stride(from: from.file + direction, to: to.file, by: direction) {
            if let piece = board.get(atRow: from.row, atFile: f) { return piece }
        }
        return board.get(atRow: to.row, atFile: to.file)
    }

    private func checkFile(from: Field, to: Field) -> (any ChessFigure)? {
        let direction = from.row < to.row ? 1 : -1
        for r in stride(from: from.row + direction, to: to.row, by: direction) {
            if let piece = board.get(atRow: r, atFile: from.file) { return piece }
        }
        return board.get(atRow: to.row, atFile: to.file)
    }

    private func checkDiagonal(from: Field, to: Field) -> (any ChessFigure)? {
        let rowDir = min(max(to.row - from.row, -1), 1)
        let fileDir = min(max(to.file - from.file, -1), 1)
        let delta = abs(from.file - to.file)
        if delta > 1 {
            for i in 1...delta {
                if let piece = board.get(atRow: from.row + i * rowDir, atFile: from.file + i * fileDir) { return piece }
            }
        }
        return board.get(atRow: to.row, atFile: to.file)
    }
}
