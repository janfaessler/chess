//
//  FenLoader.swift
//  SwiftChess
//
//  Created by Jan Fässler on 14.12.21.
//

import Foundation

public class Fen {
    
    static let StartSetup = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    
    static func loadStartingPosition() -> Position {
        return load(StartSetup)
    }
    
    static func load(_ fen:String) -> Position {
        let parts = fen.split(separator: " ")
        let figures = getFigures(String(parts[0]))
        let colorToMove = getNextMove(String(parts[1]))
        return Position(figures: figures, colorToMove: colorToMove)
    }
    
    private static func getFigures(_ position: String) -> [Figure] {
        var figures:[Figure] = []
        var row = 8
        for rowPart in position.split(separator: "/") {
            let figuresLine = parseLine(rowPart, rowNumber: row)
            figures.append(contentsOf: figuresLine)
            row -= 1
        }
        return figures
    }
    
    private static func getNextMove(_ nextMove:String) -> PieceColor{
        return nextMove.lowercased() == "w" ? .white : .black
    }
    
    private static func parseLine(_ rowPart: String.SubSequence,  rowNumber: Int) -> [Figure]{
        var figures:[Figure] = []
        var file = 1
        for part in Array(rowPart) {
            let digit = Int("\(part)")
            if (digit == nil) {
                figures.append(parsePiece(part, rowNumber: rowNumber, fileNumber: file))
                file += 1
            } else {
                file += digit!
            }
        }
        
        return figures
    }
    
    private static func parsePiece(_ str: Character, rowNumber:Int, fileNumber:Int) -> Figure {
        let pieceType = parcePieceType(str);
        let pieceColor = parseColor(str);
        return createFigure(pieceType, pieceColor, rowNumber, fileNumber)
    }
    
    private static func createFigure(_ pieceType: PieceType?, _ pieceColor: PieceColor, _ rowNumber: Int, _ fileNumber: Int) -> Figure {
        switch (pieceType) {
            case .pawn:
                return Pawn(color: pieceColor, row: rowNumber, file: fileNumber)
            case .bishop:
                return Bishop(color: pieceColor, row: rowNumber, file: fileNumber)
            case .knight:
                return Knight(color: pieceColor, row: rowNumber, file: fileNumber)
            case .rook:
                return Rook(color: pieceColor, row: rowNumber, file: fileNumber)
            case .queen:
                return Queen(color: pieceColor, row: rowNumber, file: fileNumber)
            case .king:
                return King(color: pieceColor, row: rowNumber, file: fileNumber)
        }
    }
    
    private static func parcePieceType(_ str:Character) -> PieceType? {
        switch str.lowercased() {
            case "p": return .pawn
            case "b": return .bishop
            case "n": return .knight
            case "r": return .rook
            case "q": return .queen
            case "k": return .king
            default: return nil
        }
    }
    
    private static func parseColor(_ str:Character) -> PieceColor {
        return str.isLowercase ? .black : .white
    }
}
