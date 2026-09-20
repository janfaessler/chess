import Foundation

public enum ValidationError: Error, Equatable {
    case moveNotLegalMoveOnTheBoard, pieceDoesNotExist(_ square: Square), canNotIdentifyMove, wrongSideToMove
}
