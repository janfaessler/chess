import Foundation

class Piece: Identifiable, ChessPiece, @unchecked Sendable {
    let type: PieceType
    let color: PieceColor
    private let moved: Bool
    let row: Int
    let file: Int

    init(type: PieceType, color: PieceColor, row: Int, file: Int, moved: Bool = false) {
        self.type = type
        self.color = color
        self.row = row
        self.file = file
        self.moved = moved
    }

    static func create(_ squareName: String, type: PieceType, color: PieceColor, moved: Bool = false) -> (any ChessPiece)? {
        guard let square = Square(squareName) else { return nil }
        return Piece.create(type: type, color: color, row: square.row, file: square.file, moved: moved)
    }

    static func create(type: PieceType, color: PieceColor, row: Int, file: Int, moved: Bool = false) -> any ChessPiece {
        switch type {
        case .pawn:   return Pawn(color: color, row: row, file: file, moved: moved)
        case .knight: return Knight(color: color, row: row, file: file, moved: moved)
        case .bishop: return Bishop(color: color, row: row, file: file, moved: moved)
        case .rook:   return Rook(color: color, row: row, file: file, moved: moved)
        case .queen:  return Queen(color: color, row: row, file: file, moved: moved)
        case .king:   return King(color: color, row: row, file: file, moved: moved)
        }
    }

    func equals(_ other: any ChessPiece) -> Bool {
        return row == other.row && file == other.file && type == other.type && color == other.color
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(color)
        hasher.combine(row)
        hasher.combine(file)
    }

    func canDo(move: Move) -> Bool {
        let moves = getPossibleMoves()
        return moves.contains(where: { $0.row == move.row && $0.file == move.file })
    }

    func getPossibleMoves() -> [Move] {
        fatalError("Subclasses must override getPossibleMoves()")
    }

    func isMovePossible(_ move: Move, board: any BoardQuery) -> Bool {
        guard canDo(move: move) else { return false }
        guard let intersectingPiece = board.checkNextIntersection(move) else { return true }
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
    }

    var square: Square {
        guard let s = Square(row: row, file: file) else {
            preconditionFailure("Square coordinate out of bounds: row=\(row) file=\(file)")
        }
        return s
    }
    var squareInfo: String { square.info }

    func info() -> String { "(\(color) \(type) \(squareInfo))" }
    func hasMoved() -> Bool { moved }

    func createMove(_ filename: any StringProtocol) -> Move? {
        return createMove(filename, type: .normal)
    }

    func createMove(_ row: Int, _ file: Int, _ type: MoveType = .normal) -> Move? {
        return Move(row, file, piece: Piece.create(type: self.type, color: self.color, row: self.row, file: self.file), type: type)
    }

    func createMove(_ move: any StringProtocol, type: MoveType, promoteTo: PromotionPiece) -> Move? {
        return Move(move, piece: Piece.create(type: self.type, color: self.color, row: self.row, file: self.file), type: type, promoteTo: promoteTo)
    }

    func isCaptureablePiece(_ move: Move, pieceToCapture: any ChessPiece) -> Bool {
        return move.piece.color != pieceToCapture.color && pieceToCapture.row == move.row && pieceToCapture.file == move.file
    }

    static func == (lhs: Piece, rhs: Piece) -> Bool {
        lhs.equals(rhs)
    }
}
