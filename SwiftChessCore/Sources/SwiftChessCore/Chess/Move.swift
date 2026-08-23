import Foundation

public struct Move:Identifiable, Equatable, Sendable {

    public var id:String {
        "\(startingField.info)-\(destination.info)-\(piece.color)-\(piece.type)-\(type)-\(promoteTo)"
    }

    public let destination: Field
    public let piece: any ChessFigure
    public let type: MoveType
    public let startingField: Field
    public let promoteTo: PieceType

    public var row: Int { destination.row }
    public var file: Int { destination.file }

    public init(_ r: Int, _ f: Int, piece: any ChessFigure, type: MoveType = MoveType.normal, promoteTo: PieceType = PieceType.queen) {
        self.destination = Field(row: r, file: f)
        self.piece = piece
        self.startingField = piece.field
        self.type = type
        self.promoteTo = promoteTo
    }

    public init(_ move: Move, promoteTo: PieceType) {
        self.init(move.destination.row, move.destination.file, piece: move.piece, type: MoveType.promotion, promoteTo: promoteTo)
    }

    public init?(_ fieldname: any StringProtocol, piece: any ChessFigure, type: MoveType, promoteTo: PieceType = PieceType.queen) {
        guard let field = Field(fieldname) else { return nil }
        self.destination = field
        self.piece = piece
        self.startingField = piece.field
        self.type = type
        self.promoteTo = promoteTo
    }

    public static func == (l: Move, r: Move) -> Bool {
        return l.destination == r.destination && l.piece.equals(r.piece) && l.type == r.type && l.promoteTo == r.promoteTo
    }

    public var field: Field { destination }

    public var fieldInfo: String { destination.info }

    public var info: String {
        "Move[\(destination.info), \(piece.info()), \(type), \(promoteTo)]"
    }
}
