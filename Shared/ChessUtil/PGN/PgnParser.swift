import Foundation
import RegexBuilder
import os

public class PgnParser {
    
    public static func parse(_ pgn:String) -> [PgnMove] {
        
        return parseGame(pgn)
    }
    
    private static func parseGame(_ pgn: String) -> [PgnMove] {
        let cleanedPgn = clean(pgn)

        let variations = parseVariations(cleanedPgn)
        let pgnWithoutVariations = removeVariations(cleanedPgn, variations: variations)
        return parseMoves(pgnWithoutVariations, variations)
    }
    
    private static func parseMoves(_ pgnWithoutVariations: String, _ variations: [String]) -> [PgnMove] {
        let movesArray = parse(PgnRegex.line, input: pgnWithoutVariations)
        var moves:[PgnMove] = []
        for line in movesArray {
            let moveNumber = parseMoveNumber(line)
            moves += parseMovePair(line, variations: variations.filter{ $0.hasPrefix("\(moveNumber).")})
        }
        return moves
    }
    
    private static func parseMovePair(_ line: String, variations:[String]) -> [PgnMove] {
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
        let variations = variatioinInput.map{ parseGame($0) }
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
    
    private static func clean(_ pgn: String) -> String {
        return pgn.replacing("\n\n", with: " ").replacing("\n\r", with: " ").replacing("\n", with: " ").replacing("\r", with: " ")
    }
}
