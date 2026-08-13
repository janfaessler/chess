import Foundation

enum ValidationError: Error {
    case MoveNotLegalMoveOnTheBoard, FigureDoesNotExist(_ figure:any ChessFigure), CanNotIdentifyMove
}
