import Foundation

public class PgnGameParser {
    
    public static func parse(_ pgn: String) -> PgnGame {
        var headerStrings:[String] = []
        var gameString = ""
        var gameComment:String?
        
        pgn.enumerateLines(invoking: { line, _ in
            guard !line.isEmpty else { return }
            let input = String(line.trimmingPrefix(" "))
            if input.starts(with: "[") {
                headerStrings += [input.trimmingCharacters(in: ["[","]"])]
            } else if input.starts(with: "{") {
                gameComment = parseComment(input)
                gameString += parseLineAfterComment(input)
            } else {
                gameString += input
            }
        })
        gameString = gameString.replacingOccurrences(of: "  ", with: " ")
        let moves = PgnMovesParser.parse(gameString)
        
        let result = PgnRegex.parse(PgnRegex.result, input: pgn).first
        let header = parseHeaders(headerStrings)
        
        return PgnGame(headers: header, moves: moves, result: result ?? "", comment: gameComment)
    }
    
    private static func parseHeaders(_ input:[String]) -> [String:String] {
        var results:[String:String] = [:]
        for line in input {
            let parts = line.split(separator: " ")
            guard
                let startMarkerIndex = line.firstIndex(of: "\""),
                let endMarkerIndex = line.lastIndex(of: "\"")
            else { continue }
            let contentStartIndex = line.index(after: startMarkerIndex)
            let contentEndIndex = line.index(before: endMarkerIndex)
            guard contentStartIndex < contentEndIndex else {
                results[String(parts[0])] = ""
                continue
            }
            results[String(parts[0])] = String(line[contentStartIndex...contentEndIndex])
        }
        return results
    }
    
    private static func parseComment(_ input:String) -> String {
        let commentEndMarkIndex = input.firstIndex(of: "}")!
        let startCommentIndex = input.index(after: input.startIndex)
        let endCommentIndex = input.index(before: commentEndMarkIndex)
        return String(input[startCommentIndex...endCommentIndex]).trimmingCharacters(in: [" "])
    }
    
    private static func parseLineAfterComment(_ input:String) -> String {
        let commentEndMarkIndex = input.firstIndex(of: "}")!
        let startGameIndex = input.index(after: commentEndMarkIndex)
        let endLineIndex = input.index(before: input.endIndex)

        return String(input[startGameIndex...endLineIndex])
    }
}
