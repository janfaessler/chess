import Foundation
import RegexBuilder
import os

public class PgnMovesParser {

    private enum PgnCharacter {
        static let commentOpen: Character = "{"
        static let commentClose: Character = "}"
        static let variationOpen: Character = "("
        static let variationClose: Character = ")"
    }

    public static func parse(_ pgn: String) -> [PgnMove] {
        let variations = parseVariations(pgn)
        let pgnWithoutVariations = removeVariations(pgn, variations: variations)
        return parseMoves(pgnWithoutVariations, variations)
    }
    
    private static func parseMoves(_ pgnWithoutVariations: String, _ variations: [String]) -> [PgnMove] {
        let movesArray = PgnRegex.parse(PgnRegex.line, input: pgnWithoutVariations)
        var moves:[PgnMove] = []
        for line in movesArray {
            let moveNumber = parseMoveNumber(line)
             moves += parseMovePair(line, variations: variations.filter{ $0.hasPrefix("\(moveNumber).")})
        }
        return moves
    }
    
    private static func parseMovePair(_ line: String, variations:[String]) -> [PgnMove] {
        let moveStrings = PgnRegex.parse(PgnRegex.move, input: line)
        let moveNumber = parseMoveNumber(line)

        guard let firstMove = moveStrings.first else { return [] }
        let isBlackOnly = line.hasPrefix("\(moveNumber)...")
        let whiteString: String? = isBlackOnly ? nil : firstMove
        let blackString: String? = isBlackOnly ? firstMove : (moveStrings.count > 1 ? moveStrings[1] : nil)

        var moves:[PgnMove] = []
        if let whiteString {
            let whiteVariations = variations.filter{ $0.hasPrefix("\(moveNumber)...") == false }
            moves += [parseMove(whiteString, variationInput: whiteVariations)]
        }
        if let blackString {
            let blackVariations = variations.filter{ $0.hasPrefix("\(moveNumber)...") == true }
            moves += [parseMove(blackString, variationInput: blackVariations)]
        }
        return moves
    }
    
    private static func parseMove(_ input: String, variationInput: [String]) -> PgnMove {
        let notation = parseNotation(input)
        let comment = parseComment(input)
        let variations = variationInput.map{ parse($0) }
        return PgnMove(move: notation, variations: variations, comment: comment)
    }
    
    private static func parseMoveNumber(_ input:String) -> String {
        return input.split(separator: ".").first.map(String.init) ?? ""
    }
    
    private static func parseNotation(_ input: String) -> String {
        return PgnRegex.parse(PgnRegex.notation, input: input).first ?? ""
    }
    
    private static func parseComment(_ input: String) -> String? {
        guard
            let startIndex = input.firstIndex(where: { $0 == PgnCharacter.commentOpen }),
            let endIndex = input.firstIndex(where: { $0 == PgnCharacter.commentClose })
        else {
            return nil
        }
        return String(input[input.index(after: startIndex)...input.index(before: endIndex)]).trimmingCharacters(in: [" "])
    }
    
    private static func parseVariations(_ input: String) -> [String] {
        var variations: [String] = []
        var current: String = ""
        var variationCount = 0
        var comment = false
        for char in input {
            if char == PgnCharacter.commentOpen {
                if variationCount > 0 { current.append(char) }
                comment = true
            } else if char == PgnCharacter.commentClose {
                if variationCount > 0 { current.append(char) }
                comment = false
            } else if comment {
                if variationCount > 0 { current.append(char) }
            } else if char == PgnCharacter.variationOpen {
                if variationCount > 0 { current.append(char) }
                variationCount += 1
            } else if char == PgnCharacter.variationClose {
                variationCount -= 1
                if variationCount > 0 { current.append(char) }
                if variationCount == 0 {
                    variations.append(current.trimmingCharacters(in: [" "]))
                    current = ""
                }
            } else if variationCount > 0 {
                current.append(char)
            }
        }
        return variations
    }
    
    private static func removeVariations(_ input: String, variations: [String]) -> String {
        var pgnWithoutVariations: String = input
        for variation in variations {
            let variationRange = pgnWithoutVariations.range(of: variation)
            guard let variationLowerBound = variationRange?.lowerBound,
                  let variationUpperBound = variationRange?.upperBound
            else { continue }
            let beforeVariation = pgnWithoutVariations[..<variationLowerBound].trimmingCharacters(in: [" ", "("])
            let afterVariation = pgnWithoutVariations[variationUpperBound...].trimmingCharacters(in: [" ", ")"])
            pgnWithoutVariations = "\(beforeVariation) \(afterVariation)"
        }
        return pgnWithoutVariations
    }
}
