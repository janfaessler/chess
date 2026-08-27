import Foundation

struct GameCollection: Identifiable, Hashable, Sendable {
    let id: UUID
    var name: String
    var expanded: Bool
    private(set) var games: [GameData] = []

    init(id: UUID = UUID(), name: String, expanded: Bool, games: [GameData] = []) {
        self.id = id
        self.name = name
        self.expanded = expanded
        self.games = games
    }

    mutating func addGame(_ game: GameData) {
        games.append(game)
    }

    mutating func removeGame(withId id: UUID) {
        games.removeAll { $0.id == id }
    }

    @discardableResult
    mutating func updateGame(_ game: GameData) -> Bool {
        guard let index = games.firstIndex(where: { $0.id == game.id }) else { return false }
        games[index] = game
        return true
    }
}
