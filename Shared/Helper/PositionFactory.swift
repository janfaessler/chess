import Foundation

public class PositionFactory {
    
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
        return  move.piece.getColor() == .white ? .black : .white
    }
    
    private static func createEnPassantTarget(_ move:Move) -> Field? {
        guard move.type == .Double else { return nil }
        
        let targetRow = move.piece.getColor() == .white ? move.getRow() - 1 : move.getRow() + 1
        let targetFile = move.getFile()
        
        return Field(row:targetRow, file: targetFile)
    }
    
    private static func canCastle(afterMove:Move, color:PieceColor, rookStartingFile:Int, capturedPiece:(any ChessFigure)?, oldPosition:Position) -> Bool {
    
        if afterMove.piece.getColor() == color && afterMove.piece.getType() == .king {
            return false
        }
        
        if afterMove.piece.getColor() == color && afterMove.piece.getType() == .rook {
            return afterMove.piece.getFile() != rookStartingFile
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
        
        return getOldCastlingState(oldPosition, color: color, rookStartingFile: rookStartingFile)

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
