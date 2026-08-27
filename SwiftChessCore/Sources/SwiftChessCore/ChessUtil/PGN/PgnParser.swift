import Foundation

public class PgnParser {
    public static func parse(_ pgn: String) -> [PgnGame] {
        var parser = PgnGameParser(pgn[...])
        var games: [PgnGame] = []
        while !parser.isAtEnd {
            if let game = parser.parseGame() {
                games.append(game)
            }
        }
        return games
    }
}
