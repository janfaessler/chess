import Foundation

class PositionFactory {
    
    static let startingPositionFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
    static func startingPosition() -> Position {
        return FenParser.parse(startingPositionFen)
    }
    
    static func loadPosition(_ fen:String) -> Position {
        return FenParser.parse(fen)
    }
    
    static func loadPosition(_ moves: [any StringProtocol]) -> Position? {
        var position = startingPosition()
        for notation in moves {
            guard let move = MoveFactory.create(notation, position: position) else { return nil }
            guard let newPosition = getPosition(move, cache: position, isCapture: notation.contains(NotationFactory.Capture)) else { return nil }
            position = newPosition
        }
        return position
    }
    
    static func getPosition(_ move: Move, cache: Position, isCapture: Bool) -> Position? {
        guard cache.getFigures().contains(where: { $0.equals(move.getPiece()) }) else { return nil }
        return cache.applying(move)
    }
    
    static func create(
        _ oldPosition:Position,
        afterMove:Move,
        figures: [any ChessFigure],
        capturedPiece:(any ChessFigure)? = nil
    ) -> Position {
        return Position(
            figures,
            colorToMove: createColorToMove(afterMove),
            enPassantTarget: createEnPassantTarget(afterMove),
            whiteCanCastleKingside: CastlingRules.retainsRights(afterMove: afterMove, color: .white, rookStartingFile: Rook.CastleKingsideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            whiteCanCastleQueenside: CastlingRules.retainsRights(afterMove: afterMove, color: .white, rookStartingFile: Rook.CastleQueensideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            blackCanCastleKingside: CastlingRules.retainsRights(afterMove: afterMove, color: .black, rookStartingFile: Rook.CastleKingsideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            blackCanCastleQueenside: CastlingRules.retainsRights(afterMove: afterMove, color: .black, rookStartingFile: Rook.CastleQueensideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            moveClock: oldPosition.getMoveClock() + 1,
            halfmoveClock: getHalfmoveClock(afterMove, capturedPiece != nil, oldPosition: oldPosition))
    }
    
    private static func createColorToMove(_ move:Move) -> PieceColor {
        return move.piece.getColor() == .white ? .black : .white
    }
    
    private static func createEnPassantTarget(_ move:Move) -> Field? {
        guard move.type == .Double else { return nil }
        
        let targetRow = move.piece.getColor() == .white ? move.getRow() - 1 : move.getRow() + 1
        let targetFile = move.getFile()
        
        return Field(row:targetRow, file: targetFile)
    }
    
    private static func getHalfmoveClock(_ move: Move, _ isCapture: Bool, oldPosition:Position) -> Int {
        if move.getPiece().getType() == .pawn || isCapture  {
            return 1
        } else {
            return oldPosition.getHalfmoveClock() + 1
        }
    }
}
