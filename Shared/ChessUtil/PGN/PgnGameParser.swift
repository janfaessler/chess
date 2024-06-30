import Foundation

public class PgnGameParser {
    
    public static func parse(_ pgn: String) -> PgnGame {
        var headers:[String] = []
        var gameString = ""
        var gameComment:String?
        
        pgn.enumerateLines(invoking: { line, _ in
            guard !line.isEmpty else { return }
            if line.starts(with: "[") {
                headers += [line.trimmingCharacters(in: ["[","]"])]
            }
            if line.starts(with: "{") {
                gameComment = parseComment(line)
                gameString += parseLineAfterComment(line)
            } else {
                gameString += line
            }
        })
        
        let moves = PgnMovesParser.parse(pgn)
        
        let result = PgnRegex.parse(PgnRegex.result, input: pgn).first
        
        return PgnGame(headers: headers, moves: moves, result: result ?? "", comment: gameComment)
    }
    
    private static func parseComment(_ input:String) -> String {
        let commentEndMarkIndex = input.firstIndex(of: "}")!
        let startCommentIndex = input.index(after: input.startIndex)
        let endCommentIndex = input.index(before: commentEndMarkIndex)
        return String(input[startCommentIndex...endCommentIndex])
    }
    
    private static func parseLineAfterComment(_ input:String) -> String {
        let commentEndMarkIndex = input.firstIndex(of: "}")!
        let startGameIndex = input.index(after: commentEndMarkIndex)
        let endLineIndex = input.index(before: input.endIndex)

        return String(input[startGameIndex...endLineIndex])
    }
}
