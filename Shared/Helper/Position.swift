//
//  Position.swift
//  SwiftChess
//
//  Created by Jan Fässler on 14.12.21.
//

import Foundation

public struct Position {
    public var figures:[Figure] = []
    var colorToMove:PieceColor = .white
    var whiteShortCastle:Bool
    var whiteLongCastle:Bool
    var blackShortCastle:Bool
    var blackLongCastle:Bool
    var enPassantTarget:Field?
    var moveCountSinceLastChange:Int
    var moveCount:Int
}
