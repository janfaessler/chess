import Foundation
import RegexBuilder
import os

public class Pgn {

    public static func loadMoves(_ pgn:String) -> [Move] {
        var result:[Move] = []
        var cache = Fen.loadStartingPosition()
        for pgnmove in parse(pgn) {
            let move = MoveFactory.create(pgnmove.move, position: cache)
            if  move != nil {
                result += [move!]
                cache = updateBoardCache(move!, cache: cache, isCapture: pgnmove.move.contains("x"))
            }
        }
        
        return result
    }
    
    public static func loadPosition(_ moves:[any StringProtocol]) -> Position? {
        var position = Fen.loadStartingPosition()
        for notation in moves {
            guard let move = MoveFactory.create(notation, position: position) else { return nil }
            position = updateBoardCache(move, cache: position, isCapture: notation.contains("x"))
        }
        return position
    }
    
    public static func parse(_ pgn:String) -> [PgnMove] {
        let cleanedPgn = pgn.replacing("\n\n", with: " ").replacing("\n\r", with: " ").replacing("\n", with: " ").replacing("\r", with: " ")
        
        return parsePgnString(cleanedPgn)
    }
    
    private static func parsePgnString(_ cleanedPgn: String) -> [PgnMove] {
        let variations = parseVariations(cleanedPgn)
        let pgnWithoutVariations = removeVariations(cleanedPgn, variations: variations)
        let movesArray = parse(PgnRegex.line, input: pgnWithoutVariations)
        var moves:[PgnMove] = []
        for line in movesArray {
            let moveNumber = parseMoveNumber(line)
            moves += parseLine(line, variations: variations.filter{ $0.hasPrefix("\(moveNumber).")})
        }
        return moves
    }
    
    private static func parseLine(_ line: String, variations:[String]) -> [PgnMove] {
        let moveStrings = parse(PgnRegex.move, input: line)
        let moveNumber = parseMoveNumber(line)
        
        let whiteString:String? = line.hasPrefix("\(moveNumber)...") == false ? moveStrings[0] : nil
        let blackstring:String? = line.hasPrefix("\(moveNumber)...") == true ? moveStrings[0] : (moveStrings.count > 1 ? moveStrings[1] : nil)
        

        var moves:[PgnMove] = []
        if whiteString != nil {
            let whiteVariations = variations.filter{ $0.hasPrefix("\(moveNumber)...") == false}
            moves += [parseMove(whiteString!, variatioinInput:whiteVariations)]

        }
        if blackstring != nil {
            let blackVariations = variations.filter{ $0.hasPrefix("\(moveNumber)...") == true}
            moves += [parseMove(blackstring!, variatioinInput:blackVariations)]
        }
        return moves
    }
    
    private static func parseMove(_ input: String, variatioinInput:[String]) -> PgnMove {
        let notation = parseNotation(input)
        let comment = parseComment(input)
        let variations = variatioinInput.map{ parsePgnString($0) }
        return PgnMove(move: notation, variations: variations, comment: comment)
    }
    
    private static func parseMoveNumber(_ input:String) -> String {
        let dot = input.split(separator: ".")
        return "\(dot[0])"
    }
    
    private static func parseNotation(_ input:String) -> String {
        let result = parse(PgnRegex.notation, input:input)
        return "\(result.first!)"
    }
    
    private static func parseComment(_ input:String) -> String? {
        guard 
            let startIndex =  input.firstIndex(where: { $0 == "{"}),
            let endIndex = input.firstIndex(where: { $0 == "}"})
        else {
            return nil
        }

        return String(input[input.index(after:startIndex)..<input.index(before: endIndex)])

    }
    
    private static func parseVariations(_ input:String) -> [String] {
        var variations:[String] = []
        var current:String = ""
        var variationCount = 0
        for char in input {
            if char == "(" {
                if variationCount > 0 {
                    current.append(char)
                }
                variationCount += 1
            } else if char == ")" {
                variationCount -= 1
                
                if variationCount > 0 {
                    current.append(char)
                }
                
                if variationCount == 0 {
                    variations.append(current)
                    current = ""
                }
            } else if variationCount > 0 {
                current.append(char)
            }
        }
        return variations
    }
    
    private static func removeVariations(_ input:String, variations:[String]) -> String {
        var pgnWithoutVariations:String = input
        for variation in variations {
            pgnWithoutVariations = pgnWithoutVariations.replacing(variation, with:"")
        }
        return pgnWithoutVariations
            .replacing("   ", with: " ")
            .replacing("  ", with: " ");
    }
    
    private static func parse(_ r:some RegexComponent, input:String) -> [String] {
        input.matches(of: r)
            .map{ String(input[$0.range.lowerBound..<$0.range.upperBound]).trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    
    

    
    private static func updateBoardCache(_ move:Move, cache:Position, isCapture:Bool) -> Position{
        var figures:[any ChessFigure] = cache.getFigures()
        let fig = figures.first(where: { $0.equals(move.getPiece())})!
        let capturedPiece = cache.get(atRow: move.getRow(), atFile: move.getFile())
        fig.move(row: move.getRow(), file: move.getFile())
        figures.removeAll(where: {$0.equals(move.getPiece())})
        figures.append(fig)
        if move.getType() == .Castle {
            if move.getFile() == King.CastleQueensidePosition{
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.CastleQueensideStartingFile))})!
                rook.move(row: move.getRow(), file: Rook.CastleQueensideEndFile)
            } else {
                let rook = figures.first(where: { $0.equals(Rook(color: fig.getColor(), row: fig.getRow(), file: Rook.CastleKingsideStartingFile))})!
                rook.move(row: move.getRow(), file: Rook.CastleKingsideEndFile)
            }
        }
        
        return PositionFactory.create(cache, afterMove: move, figures: figures, capturedPiece: capturedPiece)
    }
}
