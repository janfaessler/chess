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
        let updated = GameData(id: game.id, headers: headers, moves: game.moves, result: result, comment: game.comment)
        for i in collections.indices {
            if collections[i].updateGame(updated) {
                save()
                return updated
            }
        }
        return nil
    }

    func addGame(_ game: GameData, to collection: GameCollection) -> GameData? {
        guard let i = collections.firstIndex(where: { $0.id == collection.id }) else { return nil }
        collections[i].addGame(game)
        save()
        return game
    }

    func removeGame(_ game: GameData) {
        for i in collections.indices {
            collections[i].removeGame(withId: game.id)
        }
        save()
    }

    func updateCollection(_ collection: GameCollection) {
        guard let i = collections.firstIndex(where: { $0.id == collection.id }) else { return }
        collections[i] = collection
        save()
    }

    func removeCollection(_ collection: GameCollection) {
        collections.removeAll { $0.id == collection.id }
        save()
    }

    func save() {
        repository.save(collections)
    }
}
