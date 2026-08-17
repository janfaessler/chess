import Foundation

struct Move:Identifiable, Equatable {
    
    var id:String {
        "\(startingField.info)-\(field.info)-\(piece.color)-\(piece.type)-\(type)-\(promoteTo)"
    }
    
    var row:Int = 0
    var file:Int = 0
    var piece:any ChessFigure
    var type:MoveType = MoveType.Normal
    var startingField:Field
    var promoteTo:PieceType
    
    init(_ r:Int, _ f:Int, piece: any ChessFigure) {
        self.row = r
        self.file = f
        self.piece = piece
        self.startingField = piece.field
        self.promoteTo = .queen
    }
    
    init (_ r:Int, _ f:Int, piece: any ChessFigure, type: MoveType, promoteTo:PieceType = PieceType.queen){
        self.init(r,f, piece: piece)
        self.type = type
        self.promoteTo = promoteTo
    }
    
    init?(_ fieldname:any StringProtocol, piece: any ChessFigure, type: MoveType, promoteTo:PieceType = PieceType.queen) {
        guard let field = Field(fieldname) else { return nil }
        self.init(field.row, field.file, piece: piece, type: type, promoteTo: promoteTo)
    }

    static func == (l:Move, r:Move) -> Bool {
        return l.row == r.row && l.file == r.file && l.piece.equals(r.piece) && l.type == r.type && l.promoteTo == r.promoteTo
    }
    
    static func != (l:Move, r:Move) -> Bool {
        return !(l == r)
    }
    
    var field: Field {
        Field(row: row, file: file)
    }

    var fieldInfo: String {
        field.info
    }

    var info: String {
        "Move[\(field.info), \(piece.info()), \(type), \(promoteTo)]"
    }
}
