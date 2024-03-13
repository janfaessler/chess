//
//  MoveFactory.swift
//  SwiftChess
//
//  Created by Jan Fässler on 13.03.2024.
//

import Foundation

public class MoveFactory {
    
    private static let captureSeparator:String = "x"
    private static let promotionSeparator:String = "="
        
    public static func create(_ input:String, cache:BoardCache) -> Move? {
        let color = cache.getLastMove()?.piece.getColor() == PieceColor.white ? PieceColor.black : PieceColor.white

        return createPawnMove(input, color: color, cache: cache)
    }
    
    private static func createPawnMove(_ input: String, color:PieceColor, cache: BoardCache) -> Move? {
        let field = getField(input)
        let fig:ChessFigure? = getFigure(field: field, type: .pawn, color: color, cache: cache)
        if isPromotion(input) {
            return fig?.CreateMove(field, type: .Promotion)
        }
        return fig?.CreateMove(field)
    }
    
    private static func getFigure(field:String, type:PieceType, color:PieceColor, cache:BoardCache) -> ChessFigure? {
        let allFigures = cache.getFigures()
        let figuresOfTypeAndColor = allFigures.filter({ $0.getType() == type && $0.getColor() == color})
        return figuresOfTypeAndColor.first(where: { $0.CreateMove(field) != nil && $0.isMovePossible($0.CreateMove(field)!, cache: cache) })
    }
    
    private static func getField(_ input:String) -> String {
        let captureParts = input.split(separator: captureSeparator)
        let promotionParts = captureParts.last!.split(separator: promotionSeparator)
        return String(promotionParts.first!)
    }
    
    private static func isPromotion(_ input:String) -> Bool {
        let captureParts = input.split(separator: captureSeparator)
        let promotionParts = captureParts.last!.split(separator: promotionSeparator)
        return promotionParts.count > 1
    }
}
