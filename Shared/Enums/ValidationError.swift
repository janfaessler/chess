import Foundation

public enum ValidationError: Error {
    case MoveNotLegalMoveOnTheBoard, FigureDoesNotExist(_ figure:ChessFigure), CanNotIdentifyMove
}
