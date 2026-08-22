import Foundation
import RegexBuilder

public class PgnGameParser {

    public static func parse(_ pgn: String) -> PgnGame {
        let (headerStrings, gameString, gameComment) = enumerateLines(pgn)
        let moves = PgnMovesParser.parse(gameString)
        let result = parseResult(pgn)
        let header = PgnHeaderParser.parse(headerStrings)
        return PgnGame(headers: header, moves: moves, result: result, comment: gameComment)
    }
    
    private static func enumerateLines(_ pgn:String) -> ([String], String, String) {
        var headerStrings:[String] = []
        var gameString = ""
        var gameComment:String?
        
        pgn.enumerateLines(invoking: { line, _ in
            guard !line.isEmpty else { return }
            let input = String(line.trimmingPrefix(" "))
            if input.starts(with: "[") {
                headerStrings += [input]
            } else if input.starts(with: "{") {
                gameComment = parseComment(input)
                gameString += parseLineAfterComment(input)
            } else {
                gameString += input
            }
        })
        gameString = gameString.replacingOccurrences(of: "  ", with: " ")
        return (headerStrings, gameString, gameComment ?? "")
    }
    
    private static func parseComment(_ input:String) -> String {
        guard let commentEndMarkIndex = input.firstIndex(of: "}") else {
            return String(input.dropFirst()).trimmingCharacters(in: [" "])
        }
        let startCommentIndex = input.index(after: input.startIndex)
        let endCommentIndex = input.index(before: commentEndMarkIndex)
        guard startCommentIndex <= endCommentIndex else { return "" }
        return String(input[startCommentIndex...endCommentIndex]).trimmingCharacters(in: [" "])
    }
    
    private static func parseLineAfterComment(_ input:String) -> String {
        guard let commentEndMarkIndex = input.firstIndex(of: "}") else { return "" }
        let startGameIndex = input.index(after: commentEndMarkIndex)
        guard startGameIndex < input.endIndex else { return "" }
        return String(input[startGameIndex...])
    }
    
    private static func parseResult(_ pgn: String) -> String {
        PgnRegex.parse(PgnRegex.result, input: pgn).first ?? ""
    }
}
