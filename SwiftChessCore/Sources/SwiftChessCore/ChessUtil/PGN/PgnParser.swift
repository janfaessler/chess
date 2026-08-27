import Foundation

public enum PgnError: Error {
    case malformedHeader(String)
    case unexpectedToken(Character)
    case unexpectedEndOfInput
}

public class PgnParser {
    private static let logger = Log.logger("PgnParser")

    public static func parse(_ pgn: String) -> [PgnGame] {
        var parser = PgnGameParser(pgn[...])
        var games: [PgnGame] = []
        while !parser.isAtEnd {
            do {
                if let game = try parser.parseGame() {
                    games.append(game)
                }
            } catch {
                logger.error("PGN parse error: \(error)")
                break
            }
        }
        return games
    }
}
