import Foundation

public class Figure:Identifiable, Equatable, ChessFigure {

    private let type:PieceType
    private let color:PieceColor
    private var moved:Bool
    private var row:Int
    private var file:Int

    init(type:PieceType, color: PieceColor, row:Int, file:Int, moved:Bool = false) {
        self.type = type
        self.color = color
        self.row = row
        self.file = file
        self.moved = moved
    }
    
    public static func create(_ fieldname:String, type:PieceType, color: PieceColor, moved:Bool = false) -> (any ChessFigure)? {
        guard let field = Field(fieldname) else { return nil }
        return Figure.create(type: type, color: color, row: field.row, file: field.file, moved: moved)
    }
    
    public static func create(type:PieceType, color: PieceColor, row:Int, file:Int, moved:Bool = false) -> any ChessFigure {
        switch type {
            case .pawn: return Pawn(color: color, row: row, file: file, moved: moved)
            case .knight: return Knight(color: color, row: row, file: file, moved: moved)
            case .bishop: return Bishop(color: color, row: row, file: file, moved: moved)
            case .rook: return Rook(color: color, row: row, file: file, moved: moved)
            case .queen: return Queen(color: color, row: row, file: file, moved: moved)
            case .king: return King(color: color, row: row, file: file, moved: moved)
        }
    }
    
    public func equals(_ other: any ChessFigure) -> Bool {
        return row == other.getRow()
        && file == other.getFile()
        && type == other.getType()
        && color == other.getColor()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(color)
        hasher.combine(row)
        hasher.combine(file)
    }
    
    public func move(row:Int, file:Int) {
        self.row =  row
        self.file = file
        self.moved = true
    }
    
    public func canDo(move:Move) -> Bool {
        let moves = getPossibleMoves()
        return moves.contains(where:{$0.row == move.row && $0.file == move.file})
    }

    public func getPossibleMoves() -> [Move] {
        return Figure.create(type: type, color: color, row: row, file: file, moved: moved).getPossibleMoves()
    }
    
    public func isMovePossible(_ move: Move, cache:BoardCache) -> Bool {
        
        guard canDo(move: move) else {
            return false
        }

        guard let intersectingPiece = cache.getNextPiece(move) else {
            return true
        }
        
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
    }
    
    public func getRow() -> Int {
        return row
    }
    
    public func getFile() -> Int {
        return file
    }
    
    public func getColor() -> PieceColor {
        return color
    }
    
    public func getType() -> PieceType {
        return type
    }
    
    public func getFieldInfo() -> String {
        return getField().info()
    }
    
    public func getField() -> Field {
        return Field(row:row, file:file)
    }
    
    public func info() -> String {
        return "(\(color) \(type) \(getFieldInfo()))"
    }
    
    public func hasMoved() -> Bool {
        return moved
    }
    
    public static func == (l:Figure, r:Figure) -> Bool {
        return l.row == r.row && l.file == r.file && l.type == r.type && l.color == r.color
    }
    
    public static func != (l:Figure, r:Figure) -> Bool {
        return !(l == r)
    }

    public func ident() -> String {
        return ""
    }
    
    func inBoard(_ m:Move) -> Bool {
        return 1...8 ~= m.row && 1...8 ~= m.file
    }
    
    func CreateMove(_ row:Int, _ file:Int) -> Move {
        return Move(row, file, piece: self, type: .Normal)
    }
    
    public func createMove(_ filename: any StringProtocol) -> Move? {
        return createMove(filename, type: .Normal)
    }
    
    public func createMove(_ row:Int, _ file:Int, _ type:MoveType = .Normal) -> Move {
        return Move(row, file, piece: self, type: type)
    }
    
    public func createMove(_ move:any StringProtocol, type:MoveType = .Normal) -> Move? {
        return Move(move, piece: self, type: type)
    }
    
    func isCaptureablePiece(_ move: Move, pieceToCapture: (any ChessFigure)?) -> Bool {
        return move.piece.getColor() != pieceToCapture!.getColor() && pieceToCapture!.getRow() == move.row && pieceToCapture!.getFile() == move.file
    }
}
