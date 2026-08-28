import Foundation

public struct Move: Identifiable, Equatable, Hashable, Sendable {

    public var id: String {
        "\(startingSquare.info)-\(destination.info)-\(color)-\(pieceType)-\(type)-\(promoteTo)"
    }

    public let destination: Square
    public let startingSquare: Square
    public let color: PieceColor
    public let pieceType: PieceType
    public let hasMoved: Bool
    public let type: MoveType
    public let promoteTo: PromotionPiece

    public var row: Int { destination.row }
    public var file: Int { destination.file }
    public var square: Square { destination }
    public var squareInfo: String { destination.info }
    
    public init(_ move: Move, promoteTo: PromotionPiece) {
        self.destination = move.destination
        self.startingSquare = move.startingSquare
        self.color = move.color
        self.pieceType = move.pieceType
        self.hasMoved = move.hasMoved
        self.type = .promotion
        self.promoteTo = promoteTo
    }

    public init?(_ r: Int, _ f: Int, startingSquare: Square, color: PieceColor, pieceType: PieceType, hasMoved: Bool, type: MoveType = .normal, promoteTo: PromotionPiece = .queen) {
        guard let destination = Square(row: r, file: f) else { return nil }
        self.destination = destination
        self.startingSquare = startingSquare
        self.color = color
        self.pieceType = pieceType
        self.hasMoved = hasMoved
        self.type = type
        self.promoteTo = promoteTo
    }

    public init?(_ squareName: any StringProtocol, startingSquare: Square, color: PieceColor, pieceType: PieceType, hasMoved: Bool, type: MoveType, promoteTo: PromotionPiece = .queen) {
        guard let square = Square(squareName) else { return nil }
        self.destination = square
        self.startingSquare = startingSquare
        self.color = color
        self.pieceType = pieceType
        self.hasMoved = hasMoved
        self.type = type
        self.promoteTo = promoteTo
    }

    public static func == (l: Move, r: Move) -> Bool {
        l.destination == r.destination && l.startingSquare == r.startingSquare &&
        l.color == r.color && l.pieceType == r.pieceType &&
        l.type == r.type && l.promoteTo == r.promoteTo
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(destination)
        hasher.combine(startingSquare)
        hasher.combine(color)
        hasher.combine(pieceType)
        hasher.combine(type)
        hasher.combine(promoteTo)
    }

    public var info: String {
        "Move[\(destination.info), (\(color) \(pieceType) \(startingSquare.info)), \(type), \(promoteTo)]"
    }
}
