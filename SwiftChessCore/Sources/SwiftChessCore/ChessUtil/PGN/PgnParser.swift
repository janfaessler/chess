import Foundation
import RegexBuilder
import os

public class PgnParser {
    
    public static func parse(_ pgn:String) -> [PgnGame] {
        let games = parseGames(pgn)
        return games.map { PgnGameParser.parse($0) }
    }
    
    private static func parseGames(_ pgn: String) -> [String] {
        var games:[String] = []
        var currentGame = ""
        var gameParsingStarted = false
        pgn.enumerateLines(invoking: { line, _ in
            guard !line.isEmpty else { return }
            if gameParsingStarted && line.starts(with: "[Event ") {
                games += [currentGame]
                currentGame = line
                gameParsingStarted = false
            } else {
                if !line.starts(with:  "[") {
                    gameParsingStarted = true
                    currentGame += " \(line) "
                } else {
                    currentGame += "\(line) \r\n"
                }
            }
        })
        games += [currentGame]
        return games
    }

   
}
