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

    func save() {
        repository.save(collections)
    }
}
