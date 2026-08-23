import Foundation

enum ValidationError: Error {
    case moveNotLegalMoveOnTheBoard, figureDoesNotExist(_ figure: any ChessFigure), canNotIdentifyMove
}
