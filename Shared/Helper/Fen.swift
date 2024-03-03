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
            var file = 1
            for part in Array(rowPart) {
                let digit = Int("\(part)")
                if (digit == nil) {
                    let pieceType = getPieceType(part);
                    let pieceColor = getPieceColor(part);
                    switch (pieceType) {
                    case .pawn:
                        figures.append(Pawn(color: pieceColor, row: row, file: file))
                    case .bishop:
                        figures.append(Bishop(color: pieceColor, row: row, file: file))
                    case .knight:
                        figures.append(Knight(color: pieceColor, row: row, file: file))
                    case .rook:
                        figures.append(Rook(color: pieceColor, row: row, file: file))
                    case .queen:
                        figures.append(Queen(color: pieceColor, row: row, file: file))
                    case .king:
                        figures.append(King(color: pieceColor, row: row, file: file))
                    case .none:
                        continue
                    }
                    file += 1
                } else {
                    file += digit!
                }
            }
            
            row -= 1
        }
        return figures
    }
    
    private static func getNextMove(_ nextMove:String) -> PieceColor{
        return nextMove.lowercased() == "w" ? .white : .black
    }
    
    private static func getPieceType(_ str:Character) -> PieceType? {
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
    
    private static func getPieceColor(_ str:Character) -> PieceColor {
        return str.isLowercase ? .black : .white
    }
}
