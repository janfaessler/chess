//
//  ValidationError.swift
//  SwiftChessTests
//
//  Created by Jan Fässler on 08.03.2024.
//
import Foundation

public enum ValidationError: Error {
    case MoveNotLegalMoveOnTheBoard, FigureDoesNotExist(_ figure:ChessFigure), CanNotIdentifyMove
}
