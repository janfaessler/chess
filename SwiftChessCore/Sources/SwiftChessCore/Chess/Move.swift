import Foundation

public struct Move: Identifiable, Equatable, Sendable {

    public var id: String {
        "\(startingSquare.info)-\(destination.info)-\(piece.color)-\(piece.type)-\(type)-\(promoteTo)"
    }

    public let destination: Square
    public let piece: any ChessPiece
    public let type: MoveType
    public let startingSquare: Square
    public let promoteTo: PieceType

    public var row: Int { destination.row }
    public var file: Int { destination.file }

    public init(_ r: Int, _ f: Int, piece: any ChessPiece, type: MoveType = MoveType.normal, promoteTo: PieceType = PieceType.queen) {
        self.destination = Square(row: r, file: f)
        self.piece = piece
        self.startingSquare = piece.square
        self.type = type
        self.promoteTo = promoteTo
    }

    public init(_ move: Move, promoteTo: PieceType) {
        self.init(move.destination.row, move.destination.file, piece: move.piece, type: MoveType.promotion, promoteTo: promoteTo)
    }

    public init?(_ squareName: any StringProtocol, piece: any ChessPiece, type: MoveType, promoteTo: PieceType = PieceType.queen) {
        guard let square = Square(squareName) else { return nil }
        self.destination = square
        self.piece = piece
        self.startingSquare = piece.square
        self.type = type
        self.promoteTo = promoteTo
    }

    public static func == (l: Move, r: Move) -> Bool {
        return l.destination == r.destination && l.piece.equals(r.piece) && l.type == r.type && l.promoteTo == r.promoteTo
    }

    public var square: Square { destination }

    public var squareInfo: String { destination.info }

    public var info: String {
        "Move[\(destination.info), \(piece.info()), \(type), \(promoteTo)]"
    }
}
