import Foundation

public struct Position: BoardQuery, Sendable, Hashable {

    private let board: Board
    public let colorToMove: PieceColor
    public let enPassantTarget: Square?
    public let castlingRights: CastlingRights
    public let halfmoveClock: Int
    public let moveClock: Int
    public let hash: Int

    public var figures: [any ChessPiece] { board.figures }

    public init?(
        _ figures: [any ChessPiece],
        colorToMove: PieceColor,
        enPassantTarget: Square?,
        castlingRights: CastlingRights,
        moveClock: Int,
        halfmoveClock: Int
    ) {
        guard let board = Board(figures) else { return nil }
        self.init(board: board, colorToMove: colorToMove, enPassantTarget: enPassantTarget, castlingRights: castlingRights, moveClock: moveClock, halfmoveClock: halfmoveClock)
    }

    init(
        board: Board,
        colorToMove: PieceColor,
        enPassantTarget: Square?,
        castlingRights: CastlingRights,
        moveClock: Int,
        halfmoveClock: Int
    ) {
        self.board = board
        self.colorToMove = colorToMove
        self.enPassantTarget = enPassantTarget
        self.castlingRights = castlingRights
        self.moveClock = moveClock
        self.halfmoveClock = halfmoveClock
        self.hash = Position.computeHash(board: board, colorToMove: colorToMove, enPassantTarget: enPassantTarget, castlingRights: castlingRights)
    }
    
    public func get(atRow: Int, atFile: Int) -> (any ChessPiece)? {
        board.get(atRow: atRow, atFile: atFile)
    }

    public func isEmpty(atRow: Int, atFile: Int) -> Bool {
        board.isEmpty(atRow: atRow, atFile: atFile)
    }

    public func isNotEmpty(atRow: Int, atFile: Int) -> Bool {
        board.isNotEmpty(atRow: atRow, atFile: atFile)
    }

    public func checkNextIntersection(_ move: Move) -> (any ChessPiece)? {
        board.checkNextIntersection(move)
    }

    public func applying(_ move: Move) -> Position {
        let (newBoard, capturedPiece) = board.applying(move, enPassantTarget: enPassantTarget)
        return PositionFactory.create(self, afterMove: move, board: newBoard, capturedPiece: capturedPiece)
    }
    
    public static func == (lhs: Position, rhs: Position) -> Bool {
        lhs.board == rhs.board &&
        lhs.colorToMove == rhs.colorToMove &&
        lhs.castlingRights == rhs.castlingRights &&
        lhs.enPassantTarget == rhs.enPassantTarget
    }
    
    private static func computeHash(board: Board, colorToMove: PieceColor, enPassantTarget: Square?, castlingRights: CastlingRights) -> Int {
        var hasher = Hasher()
        hasher.combine(board.hash)
        hasher.combine(colorToMove)
        hasher.combine(castlingRights)
        hasher.combine(enPassantTarget)
        return hasher.finalize()
    }
}
