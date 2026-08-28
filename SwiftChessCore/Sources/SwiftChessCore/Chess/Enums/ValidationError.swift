import Foundation

public enum ValidationError: Error {
    case moveNotLegalMoveOnTheBoard, pieceDoesNotExist(_ square: Square), canNotIdentifyMove
}
