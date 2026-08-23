import Foundation

public struct Move: Identifiable, Equatable, Sendable {

    public var id: String {
        "\(startingSquare.info)-\(destination.info)-\(piece.color)-\(piece.type)-\(type)-\(promoteTo)"
    }

    public let destination: Square
    public let piece: any ChessPiece
    public let type: MoveType
    public let startingSquare: Square
    public let promoteTo: PromotionPiece

    public var row: Int { destination.row }
    public var file: Int { destination.file }

    public init?(_ r: Int, _ f: Int, piece: any ChessPiece, type: MoveType = MoveType.normal, promoteTo: PromotionPiece = .queen) {
        guard let destination = Square(row: r, file: f) else { return nil }
        self.destination = destination
        self.piece = piece
        self.startingSquare = piece.square
        self.type = type
        self.promoteTo = promoteTo
    }

    public init(_ move: Move, promoteTo: PromotionPiece) {
        self.destination = move.destination
        self.piece = move.piece
        self.startingSquare = move.startingSquare
        self.type = MoveType.promotion
        self.promoteTo = promoteTo
    }

    public init?(_ squareName: any StringProtocol, piece: any ChessPiece, type: MoveType, promoteTo: PromotionPiece = .queen) {
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
