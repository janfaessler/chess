import Foundation

public class PositionFactory {

    static let startingPositionFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    public static func startingPosition() -> Position {
        guard let position = try? FenParser.parse(startingPositionFen)
        else
        {
            fatalError("Failed to parse starting position")
        }
        return position
    }

    public static func loadPosition(_ fen:String) -> Position? {
        return try? FenParser.parse(fen)
    }

    public static func loadPosition(_ moves: [any StringProtocol]) -> Position? {
        var position = startingPosition()
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
        guard position.figures.contains(where: { $0.equals(move.piece) }) else { return nil }
        return position.applying(move)
    }
    
    static func create(
        _ oldPosition:Position,
        afterMove:Move,
        figures: [any ChessPiece],
        capturedPiece:(any ChessPiece)? = nil
    ) -> Position {
        return Position(
            figures,
            colorToMove: createColorToMove(afterMove),
            enPassantTarget: EnPassantRules.target(afterMove: afterMove),
            whiteCanCastleKingside: CastlingRules.retainsRights(afterMove: afterMove, color: .white, rookStartingFile: Rook.CastleKingsideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            whiteCanCastleQueenside: CastlingRules.retainsRights(afterMove: afterMove, color: .white, rookStartingFile: Rook.CastleQueensideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            blackCanCastleKingside: CastlingRules.retainsRights(afterMove: afterMove, color: .black, rookStartingFile: Rook.CastleKingsideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            blackCanCastleQueenside: CastlingRules.retainsRights(afterMove: afterMove, color: .black, rookStartingFile: Rook.CastleQueensideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            moveClock: oldPosition.moveClock + 1,
            halfmoveClock: getHalfmoveClock(afterMove, capturedPiece != nil, oldPosition: oldPosition))
    }
    
    private static func createColorToMove(_ move:Move) -> PieceColor {
        return move.piece.color == .white ? .black : .white
    }
    
    private static func getHalfmoveClock(_ move: Move, _ isCapture: Bool, oldPosition:Position) -> Int {
        if move.piece.type == .pawn || isCapture  {
            return 0
        } else {
            return oldPosition.halfmoveClock + 1
        }
    }
}
