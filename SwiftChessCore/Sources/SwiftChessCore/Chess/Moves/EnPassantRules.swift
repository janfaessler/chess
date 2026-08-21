import Foundation

struct EnPassantRules {

    static func target(afterMove move: Move) -> Field? {
        guard move.type == .Double else { return nil }
        let targetRow = move.piece.color == .white ? move.row - 1 : move.row + 1
        return Field(row: targetRow, file: move.file)
    }

    static func canEnPassant(_ move: Move, position: Position) -> Bool {
        guard let target = position.enPassantTarget else { return false }
        return move.field == target
    }

    static func isEnPassant(_ move: Move, position: Position) -> Bool {
        canEnPassant(move, position: position) && position.isEmpty(atRow: move.row, atFile: move.file)
    }

    static func capturedPawnField(for move: Move) -> Field {
        Field(row: move.piece.row, file: move.file)
    }
}
