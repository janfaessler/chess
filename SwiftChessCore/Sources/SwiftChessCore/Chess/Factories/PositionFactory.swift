import Foundation

public enum PositionFactory {

    static let startingPositionFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    public static func startingPosition() throws -> Position {
        try FenParser.parse(startingPositionFen)
    }

    public static func loadPosition(_ fen:String) -> Position? {
        return try? FenParser.parse(fen)
    }

    public static func loadPosition(_ moves: [any StringProtocol]) -> Position? {
        guard var position = try? startingPosition() else { return nil }
        for notation in moves {
            guard let newPosition = apply(notation, to: position) else { return nil }
            position = newPosition
        }
        return position
    }

    public static func apply(_ notation: any StringProtocol, to position: Position) -> Position? {
        guard let move = MoveFactory.create(notation, position: position) else { return nil }
        return getPosition(move, position: position)
    }

    static func getPosition(_ move: Move, position: Position) -> Position? {
        guard position.get(atRow: move.startingSquare.row, atFile: move.startingSquare.file) != nil else { return nil }
        return position.applying(move)
    }

    static func create(
        _ oldPosition: Position,
        afterMove: Move,
        board: Board,
        capturedPiece: (any ChessPiece)? = nil
    ) -> Position {
        return Position(
            board: board,
            colorToMove: createColorToMove(afterMove),
            enPassantTarget: EnPassantRules.target(afterMove: afterMove),
            castlingRights: CastlingRules.updatedRights(afterMove: afterMove, capturedPiece: capturedPiece, oldPosition: oldPosition),
            moveClock: oldPosition.moveClock + 1,
            halfmoveClock: getHalfmoveClock(afterMove, capturedPiece != nil, oldPosition: oldPosition))
    }

    private static func createColorToMove(_ move:Move) -> PieceColor {
        return move.color == .white ? .black : .white
    }

    private static func getHalfmoveClock(_ move: Move, _ isCapture: Bool, oldPosition:Position) -> Int {
        if move.pieceType == .pawn || isCapture {
            return 0
        } else {
            return oldPosition.halfmoveClock + 1
        }
    }
}
