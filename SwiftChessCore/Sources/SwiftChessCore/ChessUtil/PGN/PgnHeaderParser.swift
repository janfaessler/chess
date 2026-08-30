import Foundation
import RegexBuilder

public enum PgnHeaderParser {
    
    nonisolated(unsafe) static let header = Regex {
        One("[")
        Capture {
            OneOrMore(.word)
        }
        One(" \"")
        Capture {
            OneOrMore(.any, .reluctant)
        }
        One("\"]")
    }
    
    public static func parse(_ input:[String]) -> [String: String] {
        var results:[String:String] = [:]
        for line in input {
            if let match = line.firstMatch(of: header) {
                results[String(match.output.1)] = String(match.output.2)
            }
        }
        return results
    }

}
