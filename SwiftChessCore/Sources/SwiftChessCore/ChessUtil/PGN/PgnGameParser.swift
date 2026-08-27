import Foundation

struct PgnGameParser {
    private var remaining: Substring

    init(_ input: Substring) {
        remaining = input
    }

    var isAtEnd: Bool { remaining.isEmpty }

    mutating func parseGame() throws -> PgnGame? {
        skipWhitespace()
        guard !isAtEnd else { return nil }
        let headers = parseHeaders()
        skipWhitespace()
        let gameComment = parseComment()
        let (moves, result) = parseMoves(inVariation: false)
        skipWhitespace()
        return PgnGame(headers: headers, moves: moves, result: result, comment: gameComment)
    }

    private mutating func parseHeaders() -> [String: String] {
        var lines: [String] = []
        while remaining.first == "[" {
            let line = remaining.prefix(while: { $0 != "\n" && $0 != "\r" })
            lines.append(String(line))
            remaining = remaining[line.endIndex...]
            skipWhitespace()
        }
        return PgnHeaderParser.parse(lines)
    }
    
    private mutating func parseMoves(inVariation: Bool) -> (moves: [PgnMove], result: String) {
        var moves: [PgnMove] = []
        var result = ""

        while true {
            skipWhitespace()
            guard !isAtEnd, let first = remaining.first else { break }
            
            if first == ")" {
                remaining.removeFirst()
                if inVariation { break }
                continue
            }

            if isAtResult() {
                result = consumeResult()
                break
            }

            if first.isNumber {
                let peek = remaining.drop(while: \.isNumber)
                if peek.first == "." {
                    skipMoveNumber()
                    continue
                }
                remaining = remaining.drop(while: { !$0.isWhitespace })
                continue
            }

            if first == "(" {
                remaining.removeFirst()
                let (varMoves, _) = parseMoves(inVariation: true)
                if !moves.isEmpty {
                    moves[moves.count - 1] = moves[moves.count - 1].addingVariation(varMoves)
                }
                continue
            }

            if first == "{" {
                if let commentText = parseComment(), !moves.isEmpty {
                    moves[moves.count - 1] = moves[moves.count - 1].addingComment(commentText)
                }
                continue
            }

            guard let notation = parseNotation() else {
                remaining.removeFirst()
                continue
            }

            let symbol = parseSymbolAnnotation()
            skipWhitespace()
            let nag = parseNAG()
            let annotation = nag ?? symbol

            skipWhitespace()
            let commentText = remaining.first == "{" ? parseComment() : nil

            var move = PgnMove(move: notation, annotation: annotation, variations: [], comment: nil)
            if let commentText {
                move = move.addingComment(commentText)
            }
            moves.append(move)

            skipWhitespace()
            while remaining.first == "(" {
                remaining.removeFirst()
                let (varMoves, _) = parseMoves(inVariation: true)
                moves[moves.count - 1] = moves[moves.count - 1].addingVariation(varMoves)
                skipWhitespace()
            }
        }

        return (moves, result)
    }

    private mutating func parseComment() -> String? {
        guard remaining.first == "{" else { return nil }
        remaining.removeFirst()
        let content = remaining.prefix(while: { $0 != "}" })
        remaining = remaining[content.endIndex...]
        if remaining.first == "}" { remaining.removeFirst() }
        let normalized = content.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return normalized.isEmpty ? nil : normalized
    }

    private mutating func skipMoveNumber() {
        remaining = remaining.drop(while: \.isNumber)
        remaining = remaining.drop(while: { $0 == "." })
    }

    private func isNotationChar(_ c: Character) -> Bool {
        c.isLetter || c.isNumber || c == "-" || c == "=" || c == "+" || c == "#" || c == "x"
    }

    private mutating func parseNotation() -> String? {
        let word = remaining.prefix(while: isNotationChar)
        guard !word.isEmpty else { return nil }
        remaining = remaining[word.endIndex...]
        return String(word)
    }

    private func isAnnotationChar(_ c: Character) -> Bool {
        c == "!" || c == "?"
    }

    private mutating func parseSymbolAnnotation() -> MoveAnnotation? {
        let glyphs = remaining.prefix(while: isAnnotationChar)
        guard !glyphs.isEmpty else { return nil }
        remaining = remaining[glyphs.endIndex...]
        return MoveAnnotation.fromSymbol(String(glyphs))
    }

    private mutating func parseNAG() -> MoveAnnotation? {
        guard remaining.first == "$" else { return nil }
        remaining.removeFirst()
        let digits = remaining.prefix(while: \.isNumber)
        guard !digits.isEmpty else { return nil }
        remaining = remaining[digits.endIndex...]
        return MoveAnnotation.fromNAG(String(digits))
    }

    private func isAtResult() -> Bool {
        if remaining.first == "*" { return true }
        let t = remaining.prefix(7)
        return t.hasPrefix("1-0") || t.hasPrefix("0-1") || t.hasPrefix("1/2-1/2")
    }

    private mutating func consumeResult() -> String {
        if remaining.first == "*" { remaining.removeFirst(); return "*" }
        if remaining.hasPrefix("1/2-1/2") { remaining = remaining.dropFirst(7); return "1/2-1/2" }
        if remaining.hasPrefix("1-0") { remaining = remaining.dropFirst(3); return "1-0" }
        if remaining.hasPrefix("0-1") { remaining = remaining.dropFirst(3); return "0-1" }
        return ""
    }

    private mutating func skipWhitespace() {
        remaining = remaining.drop(while: \.isWhitespace)
    }
}

extension PgnMove {
    func addingVariation(_ variation: [PgnMove]) -> PgnMove {
        PgnMove(
            move: move,
            annotation: annotation,
            variations: variations + [variation],
            comment: comment,
            highlights: highlights,
            arrows: arrows
        )
    }

    func addingComment(_ text: String) -> PgnMove {
        PgnMove(
            move: move,
            annotation: annotation,
            variations: variations,
            comment: PgnHighlightArrowParser.stripCommands(text),
            highlights: PgnHighlightArrowParser.parseHighlights(text),
            arrows: PgnHighlightArrowParser.parseArrows(text)
        )
    }
}
