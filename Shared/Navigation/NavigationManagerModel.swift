import Foundation
import os

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
            await MainActor.run {
                self.collections.append(
                    GameCollection(name: url.lastPathComponent, expanded: true, games: gameDataArray)
                )
                self.save()
            }
        }
    }

    func save() {
        repository.save(collections)
    }
}
