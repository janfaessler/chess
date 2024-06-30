import Foundation

public class PositionFactory {
    
    public static let startingPositionFen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
    public static func startingPosition() -> Position {
        return FenParser.parse(startingPositionFen)
    }
    
    public static func loadPosition(_ fen:String) -> Position {
        return FenParser.parse(fen)
    }
    
    public static func loadPosition(_ moves:[any StringProtocol]) -> Position? {
        var position = startingPosition()
        for notation in moves {
            guard let move = MoveFactory.create(notation, position: position) else { return nil }
            position = getPosition(move, cache: position, isCapture: notation.contains(NotationFactory.Capture))
        }
        return position
    }
    
    public static func getPosition(_ move:Move, cache:Position, isCapture:Bool) -> Position{
        var figures:[any ChessFigure] = cache.getFigures()
        let fig = figures.first(where: { $0.equals(move.getPiece())})!
        let capturedPiece = cache.get(atRow: move.getRow(), atFile: move.getFile())
        fig.move(row: move.getRow(), file: move.getFile())
        figures.removeAll(where: {$0.equals(move.getPiece())})
        figures.append(fig)
        if move.getType() == .Castle {
            if move.getFile() == King.CastleQueensidePosition{
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.CastleQueensideStartingFile))})!
                rook.move(row: move.getRow(), file: Rook.CastleQueensideEndFile)
            } else {
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.CastleKingsideStartingFile))})!
                rook.move(row: move.getRow(), file: Rook.CastleKingsideEndFile)
            }
        }
        
        return PositionFactory.create(cache, afterMove: move, figures: figures, capturedPiece: capturedPiece)
    }
    
    public static func create(
        _ oldPosition:Position,
        afterMove:Move,
        figures: [any ChessFigure]? = nil,
        capturedPiece:(any ChessFigure)? = nil
    ) -> Position {
        return Position(
            figures ?? oldPosition.getFigures(),
            colorToMove: createColorToMove(afterMove),
            enPassantTarget: createEnPassantTarget(afterMove),
            whiteCanCastleKingside: canCastle(afterMove: afterMove, color: .white, rookStartingFile: Rook.CastleKingsideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            whiteCanCastleQueenside: canCastle(afterMove: afterMove, color: .white, rookStartingFile: Rook.CastleQueensideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            blackCanCastleKingside: canCastle(afterMove: afterMove, color: .black, rookStartingFile: Rook.CastleKingsideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
            blackCanCastleQueenside: canCastle(afterMove: afterMove, color: .black, rookStartingFile: Rook.CastleQueensideStartingFile, capturedPiece: capturedPiece, oldPosition: oldPosition),
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
    
    private static func canCastle(afterMove:Move, color:PieceColor, rookStartingFile:Int, capturedPiece:(any ChessFigure)?, oldPosition:Position) -> Bool {
    
        let oldState = getOldCastlingState(oldPosition, color: color, rookStartingFile: rookStartingFile)
        
        if oldState == false { return false }
        
        if afterMove.piece.getColor() == color && afterMove.piece.getType() == .king {
            return false
        }
        
        if afterMove.piece.getColor() == color && afterMove.piece.getType() == .rook {
            return afterMove.piece.getFile() != rookStartingFile && getOldCastlingState(oldPosition, color: color, rookStartingFile: rookStartingFile)
        }
        
        if color == .white {
            if capturedPiece != nil && capturedPiece?.getColor() == .white && capturedPiece?.getType() == .rook {
                if capturedPiece?.getFile() == Rook.CastleKingsideStartingFile { return false }
                if capturedPiece?.getFile() == Rook.CastleQueensideStartingFile { return false }
            }
        } else {
            if capturedPiece != nil && capturedPiece?.getColor() == .black && capturedPiece?.getType() == .rook {
                if capturedPiece?.getFile() == Rook.CastleKingsideStartingFile { return false }
                if capturedPiece?.getFile() == Rook.CastleQueensideStartingFile { return false }
            }
        }
        
        return oldState

    }
    
    private static func getOldCastlingState(_ oldPosition: Position, color: PieceColor, rookStartingFile: Int)  -> Bool {
        if (color == .white) {
            if rookStartingFile == Rook.CastleKingsideStartingFile {
                return oldPosition.canWhiteCastleKingside()
            } else {
                return oldPosition.canWhiteCastleQueenside()
            }
        } else {
            if rookStartingFile == Rook.CastleKingsideStartingFile {
                return oldPosition.canBlackCastleKingside()
            } else {
                return oldPosition.canBlackCastleQueenside()
            }
        }
    }
    
    private static func getHalfmoveClock(_ move: Move, _ isCapture: Bool, oldPosition:Position) -> Int {
        if move.getPiece().getType() == .pawn || isCapture  {
            return 1
        } else {
            return oldPosition.getHalfmoveClock() + 1
        }
    }
}
