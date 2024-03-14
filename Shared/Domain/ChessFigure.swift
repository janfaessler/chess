//
//  ChessFigure.swift
//  SwiftChess
//
//  Created by Jan Fässler on 09.03.2024.
//

import Foundation

public protocol ChessFigure {
    func move(row:Int, file:Int)
    func canDo(move:Move) -> Bool
    func getPossibleMoves() -> [Move]
    func isMovePossible(_ move: Move, cache:BoardCache) -> Bool
    func getRow() -> Int
    func getFile() -> Int
    func getColor() -> PieceColor
    func getType() -> PieceType
    func equals(_ other:ChessFigure) -> Bool
    func getField() -> Field
    func getFieldInfo() -> String
    func hasMoved() -> Bool
    func info() -> String
    func ident() -> String
    func createMove(_ row:Int, _ file:Int, _ type:MoveType) -> Move
    func createMove(_ filename:any StringProtocol, type:MoveType) -> Move?
    func createMove(_ filename:any StringProtocol) -> Move?
}
