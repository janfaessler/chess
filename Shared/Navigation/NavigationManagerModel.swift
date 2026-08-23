import Foundation
import os

@MainActor
@Observable
public class NavigationManagerModel {

    var collections: [GameCollection] = []
    var errorAlert: String?

    private let gameDataRepo: GameCollectionRepository
    private let fileRepo: FileRepository

    init(gameDataRepo: GameCollectionRepository, fileRepo: FileRepository) {
        self.gameDataRepo = gameDataRepo
        self.fileRepo = fileRepo
        do {
            collections = try gameDataRepo.load()
        }
        catch {
            errorAlert = "Failed to load collections: \(error.localizedDescription)"
        }
    }

    func openFiles(urls: [URL]) async {
        for url in urls {
            do {
                let gameDataArray = try await fileRepo.importGames(from: url)
                collections.append(
                    GameCollection(name: url.lastPathComponent, expanded: true, games: gameDataArray)
                )
                save()
            }
            catch {
                errorAlert = "Failed to import \(url.lastPathComponent): \(error.localizedDescription)"
            }
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
        do {
            try gameDataRepo.save(collections)
        }
        catch {
            errorAlert = "Failed to save collections: \(error.localizedDescription)"
        }        
    }

    func clearError() {
        errorAlert = nil
    }
}
