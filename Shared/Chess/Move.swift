import Foundation

public struct Move:Identifiable, Equatable {
    
    public let id:String = UUID().uuidString
    
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
        self.startingField = piece.getField()
        self.promoteTo = .queen
    }
    
    public init (_ r:Int, _ f:Int, piece: any ChessFigure, type: MoveType, promoteTo:PieceType = PieceType.queen){
        self.init(r,f, piece: piece)
        self.type = type
        self.promoteTo = promoteTo
    }
    
    public init?(_ fieldname:any StringProtocol, piece: any ChessFigure, type: MoveType, promoteTo:PieceType = PieceType.queen) {
        guard let field = Field(fieldname) else { return nil }
        self.init(field.row, field.file, piece: piece, type: type, promoteTo: promoteTo)
    }

    public static func == (l:Move, r:Move) -> Bool {
        return l.row == r.row && l.file == r.file && l.piece.equals(r.piece) && l.type == r.type
    }
    
    static func != (l:Move, r:Move) -> Bool {
        return !(l == r)
    }
    
    public func getRow() -> Int {
        return row
    }
    
    public func getFile() -> Int {
        return file
    }
    
    public func getType() -> MoveType {
        return type
    }
    
    public func getFieldInfo() -> String {
        return getField().info()
    }
    
    public func getField() -> Field {
        return Field(row:row, file:file)
    }
    
    public func getStartingField() -> Field {
        return startingField
    }
    
    public func getPiece() -> any ChessFigure {
        return piece
    }
    
    public func isCastling() -> Bool {
        return piece.getType() == .king && type == .Castle
    }
    
    public func info() -> String {
        "Move[\(Field(row: row, file: file).info()), \(piece.info()), \(type), \(promoteTo)]"
    }
}
