import Foundation

struct GameCollection: Hashable {
    let id: UUID
    let name: String
    var expanded: Bool
    var games: [GameData] = []

    init(id: UUID = UUID(), name: String, expanded: Bool, games: [GameData] = []) {
        self.id = id
        self.name = name
        self.expanded = expanded
        self.games = games
    }
}
