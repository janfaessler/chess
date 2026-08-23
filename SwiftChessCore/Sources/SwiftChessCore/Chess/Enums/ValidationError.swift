import Foundation

enum ValidationError: Error {
    case moveNotLegalMoveOnTheBoard, pieceDoesNotExist(_ piece: any ChessPiece), canNotIdentifyMove
}
