import Foundation
import RegexBuilder

public class PgnRegex {
    
    public static func parse(_ r:some RegexComponent, input:String) -> [String] {
        input.matches(of: r)
            .map{ String(input[$0.range.lowerBound..<$0.range.upperBound]).trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    
    
    public static func parseGames(_ input:String) -> [String] {
        var startIndex = input.startIndex
        return input
            .matches(of: PgnRegex.result)
            .map {
                let game = String(input[startIndex..<$0.range.upperBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                startIndex = $0.range.upperBound
                return game
            }
    }
    
    public static let line = Regex {
        Repeat(1...) {
            One(.digit)
        }
        Repeat(1...3) {
            "."
        }
        Optionally(.whitespace)
        Repeat(1...2) {
            Capture {
                move
            }
        }
    }.anchorsMatchLineEndings()
    
    public static let move =  Regex {
        Capture {
           notation
        }
        Optionally {
            Capture {
                annotation
            }
        }
        Optionally {
            Capture {
                numericAnnotation
            }
        }
        Optionally {
            Capture {
                comment
            }
        }
        Optionally {
            Capture {
                result
            }
        }
        Optionally {
            Optionally(.whitespace)

            Capture {
                Repeat(1...) {
                    One(.digit)
                }
                One("...")
            }
        }
        Optionally(.whitespace)

    }
    
    public static let notation = Regex {
        ChoiceOf {
            castle
            normalMove
        }
    }
    
    public static let castle = Regex {
        One(.anyOf("Oo0"))
        "-"
        One(.anyOf("Oo0"))
        Optionally {
            Capture {
                Regex {
                    "-"
                    One(.anyOf("Oo0"))
                }
            }
        }
    }
    public static let normalMove = Regex {
        Optionally(.anyOf("KQRBN"))
        Optionally(("a"..."h"))
        Optionally(("1"..."8"))
        Optionally {
            "x"
        }
        ("a"..."h")
        ("1"..."8")
        Optionally {
            Capture {
                Regex {
                    "="
                    One(.anyOf("QRBN"))
                }
            }
        }
        Optionally(.anyOf("+#"))
    }
    
    public static let annotation = Regex  {
        Repeat(1...2) {
            One(.anyOf("?!"))
        }
    }
    
    public static let numericAnnotation = Regex  {
        Optionally(.whitespace)
        "$"
        One(.digit)
    }
    
    public static let comment = Regex {
        Optionally(.whitespace)
        "{"
        Optionally {
            Regex {
                "["
                OneOrMore(.reluctant) {
                    /./
                }
                "]"
            }
        }
        ZeroOrMore(.reluctant) {
            /./
        }
        "}"
    }
    
    public static let result = Regex {
        One(.whitespace)
        Capture {
            ChoiceOf {
                "1-0"
                "0-1"
                "1/2-1/2"
            }
        }
    }
}
