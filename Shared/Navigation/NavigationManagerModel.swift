import Foundation
import os

@MainActor
@Observable
public class NavigationManagerModel {

    var collections: [GameCollection] = []

    private let repository: GameCollectionRepository

    init(repository: GameCollectionRepository) {
        self.repository = repository
        collections = repository.load()
    }

    func openFiles(urls: [URL]) async {
        for url in urls {
            let gameDataArray = await repository.importGames(from: url)
            collections.append(
                GameCollection(name: url.lastPathComponent, expanded: true, games: gameDataArray)
            )
            save()
        }
    }

    func updateGame(_ game: GameData, headers: [String: String], result: String) -> GameData? {
        for i in collections.indices {
            if let j = collections[i].games.firstIndex(where: { $0.id == game.id }) {
                let updated = GameData(id: game.id, headers: headers, moves: game.moves, result: result, comment: game.comment)
                collections[i].games[j] = updated
                save()
                return updated
            }
        }
        return nil
    }

    func save() {
        repository.save(collections)
    }
}
