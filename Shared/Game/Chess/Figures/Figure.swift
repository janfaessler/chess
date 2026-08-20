import Foundation

class Figure:Identifiable, ChessFigure, @unchecked Sendable {
    let type:PieceType
    let color:PieceColor
    private let moved:Bool
    let row:Int
    let file:Int

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
        return row == other.row
        && file == other.file
        && type == other.type
        && color == other.color
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
    
    var field: Field {
        Field(row: row, file: file)
    }

    var fieldInfo: String {
        field.info
    }

    func info() -> String {
        return "(\(color) \(type) \(fieldInfo))"
    }
    
    func hasMoved() -> Bool {
        return moved
    }

    func inBoard(_ m:Move) -> Bool {
        return 1...8 ~= m.row && 1...8 ~= m.file
    }

    func movesAlongRays(_ directions: [(row: Int, file: Int)]) -> [Move] {
        var moves:[Move] = []
        for direction in directions {
            var r = row + direction.row
            var f = file + direction.file
            while 1...8 ~= r && 1...8 ~= f {
                moves.append(createMove(r, f))
                r += direction.row
                f += direction.file
            }
        }
        return moves
    }

    func createMove(_ filename: any StringProtocol) -> Move? {
        return createMove(filename, type: .Normal)
    }

    func createMove(_ row:Int, _ file:Int, _ type:MoveType = .Normal) -> Move {
        return Move(row, file, piece: Figure.create(type: self.type, color: self.color, row: self.row, file: self.file), type: type)
    }

    func createMove(_ move:any StringProtocol, type:MoveType = .Normal, promoteTo:PieceType = .queen) -> Move? {
        return Move(move, piece: Figure.create(type: self.type, color: self.color, row: self.row, file: self.file), type: type, promoteTo: promoteTo)
    }
    
    func isCaptureablePiece(_ move: Move, pieceToCapture: any ChessFigure) -> Bool {
        return move.piece.color != pieceToCapture.color && pieceToCapture.row == move.row && pieceToCapture.file == move.file
    }
    
    static func == (lhs: Figure, rhs: Figure) -> Bool {
        lhs.equals(rhs)
    }
}
