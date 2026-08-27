import Foundation

public enum ValidationError: Error {
    case moveNotLegalMoveOnTheBoard, pieceDoesNotExist(_ piece: any ChessPiece), canNotIdentifyMove
}
