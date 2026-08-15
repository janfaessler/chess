import Foundation

class Figure:Identifiable, ChessFigure {
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
    
    static func create(_ fieldname:String, type:PieceType, color: PieceColor, moved:Bool = false) -> (any ChessFigure)? {
        guard let field = Field(fieldname) else { return nil }
        return Figure.create(type: type, color: color, row: field.row, file: field.file, moved: moved)
    }
    
    static func create(type:PieceType, color: PieceColor, row:Int, file:Int, moved:Bool = false) -> any ChessFigure {
        switch type {
            case .pawn: return Pawn(color: color, row: row, file: file, moved: moved)
            case .knight: return Knight(color: color, row: row, file: file, moved: moved)
            case .bishop: return Bishop(color: color, row: row, file: file, moved: moved)
            case .rook: return Rook(color: color, row: row, file: file, moved: moved)
            case .queen: return Queen(color: color, row: row, file: file, moved: moved)
            case .king: return King(color: color, row: row, file: file, moved: moved)
        }
    }
    
    func equals(_ other: any ChessFigure) -> Bool {
        return row == other.getRow()
        && file == other.getFile()
        && type == other.getType()
        && color == other.getColor()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(color)
        hasher.combine(row)
        hasher.combine(file)
    }
    
    func canDo(move:Move) -> Bool {
        let moves = getPossibleMoves()
        return moves.contains(where:{$0.row == move.row && $0.file == move.file})
    }

    func getPossibleMoves() -> [Move] {
        fatalError("Subclasses must override getPossibleMoves()")
    }
    
    func isMovePossible(_ move: Move, position:Position) -> Bool {
        
        guard canDo(move: move) else {
            return false
        }

        guard let intersectingPiece = position.getNextPiece(move) else {
            return true
        }
        
        return isCaptureablePiece(move, pieceToCapture: intersectingPiece)
    }
    
    func getRow() -> Int {
        return row
    }
    
    func getFile() -> Int {
        return file
    }
    
    func getColor() -> PieceColor {
        return color
    }
    
    func getType() -> PieceType {
        return type
    }
    
    func getFieldInfo() -> String {
        return getField().info()
    }
    
    func getField() -> Field {
        return Field(row:row, file:file)
    }
    
    func info() -> String {
        return "(\(color) \(type) \(getFieldInfo()))"
    }
    
    func hasMoved() -> Bool {
        return moved
    }

    func ident() -> String {
        fatalError("Subclasses must override ident()")
    }
    
    func inBoard(_ m:Move) -> Bool {
        return 1...8 ~= m.row && 1...8 ~= m.file
    }

    func createMove(_ row:Int, _ file:Int) -> Move {
        return Move(row, file, piece: Figure.create(type: self.getType(), color: self.getColor(), row: self.getRow(), file: self.getFile()), type: .Normal)
    }
    
    func createMove(_ filename: any StringProtocol) -> Move? {
        return createMove(filename, type: .Normal)
    }
    
    func createMove(_ row:Int, _ file:Int, _ type:MoveType = .Normal) -> Move {
        return Move(row, file, piece: Figure.create(type: self.getType(), color: self.getColor(), row: self.getRow(), file: self.getFile()), type: type)
    }

    func createMove(_ move: any StringProtocol, type: MoveType) -> Move? {
        return Move(move, piece: Figure.create(type: self.getType(), color: self.getColor(), row: self.getRow(), file: self.getFile()), type: type)
    }
    
    func createMove(_ move:any StringProtocol, type:MoveType = .Normal, promoteTo:PieceType = .queen) -> Move? {
        return Move(move, piece: Figure.create(type: self.getType(), color: self.getColor(), row: self.getRow(), file: self.getFile()), type: type, promoteTo: promoteTo)
    }
    
    func isCaptureablePiece(_ move: Move, pieceToCapture: any ChessFigure) -> Bool {
        return move.piece.getColor() != pieceToCapture.getColor() && pieceToCapture.getRow() == move.row && pieceToCapture.getFile() == move.file
    }
    
    static func == (lhs: Figure, rhs: Figure) -> Bool {
        lhs.equals(rhs)
    }
}
