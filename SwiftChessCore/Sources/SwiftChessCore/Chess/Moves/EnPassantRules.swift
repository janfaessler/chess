import Foundation

struct EnPassantRules {

    static func target(afterMove move: Move) -> Square? {
        guard move.type == .double else { return nil }
        let targetRow = move.piece.color == .white ? move.row - 1 : move.row + 1
        return Square(row: targetRow, file: move.file)
    }

    static func canEnPassant(_ move: Move, position: Position) -> Bool {
        guard let target = position.enPassantTarget else { return false }
        return move.square == target
    }

    static func isEnPassant(_ move: Move, position: Position) -> Bool {
        canEnPassant(move, position: position) && position.isEmpty(atRow: move.row, atFile: move.file)
    }

    static func capturedPawnSquare(for move: Move) -> Square {
        Square(row: move.piece.row, file: move.file)
    }
}
