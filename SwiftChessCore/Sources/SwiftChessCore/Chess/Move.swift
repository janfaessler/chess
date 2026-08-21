import Foundation

public struct Move:Identifiable, Equatable, Sendable {

    public var id:String {
        "\(startingField.info)-\(field.info)-\(piece.color)-\(piece.type)-\(type)-\(promoteTo)"
    }

    public let row:Int
    public let file:Int
    public let piece:any ChessFigure
    public let type:MoveType
    public let startingField:Field
    public let promoteTo:PieceType

    public init(_ r:Int, _ f:Int, piece: any ChessFigure, type: MoveType = MoveType.Normal, promoteTo:PieceType = PieceType.queen) {
        self.row = r
        self.file = f
        self.piece = piece
        self.startingField = piece.field
        self.type = type
        self.promoteTo = promoteTo
    }

    public init(_ move:Move, promoteTo:PieceType) {
        self.init(move.row, move.file, piece: move.piece, type: MoveType.Promotion, promoteTo: promoteTo)
    }

    public init?(_ fieldname:any StringProtocol, piece: any ChessFigure, type: MoveType, promoteTo:PieceType = PieceType.queen) {
        guard let field = Field(fieldname) else { return nil }
        self.init(field.row, field.file, piece: piece, type: type, promoteTo: promoteTo)
    }

    public static func == (l:Move, r:Move) -> Bool {
        return l.row == r.row && l.file == r.file && l.piece.equals(r.piece) && l.type == r.type && l.promoteTo == r.promoteTo
    }

    public static func != (l:Move, r:Move) -> Bool {
        return !(l == r)
    }

    public var field: Field {
        Field(row: row, file: file)
    }

    public var fieldInfo: String {
        field.info
    }

    public var info: String {
        "Move[\(field.info), \(piece.info()), \(type), \(promoteTo)]"
    }
}
