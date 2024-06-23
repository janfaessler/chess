import Foundation
import RegexBuilder
import os

public class PgnParser {
    
    public static func parse(_ pgn:String) -> [PgnMove] {
        
        var headers:[String] = []
        var gameString = ""
        
        pgn.enumerateLines(invoking: { line, _ in
            guard !line.isEmpty else { return }
            if line.starts(with: "[") {
                headers += [line.trimmingCharacters(in: ["[","]"])]
            }
            gameString += " \(line)"
        })
        
        return PgnMovesParser.parse(pgn)
    }}
