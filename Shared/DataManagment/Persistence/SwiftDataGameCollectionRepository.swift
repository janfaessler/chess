import Foundation
import SwiftData

@MainActor
final class SwiftDataGameCollectionRepository: GameCollectionRepository {

    private let logger = Log.logger("SwiftDataGameCollectionRepository")

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func load() -> [GameCollection] {
        do {
            let descriptor = FetchDescriptor<CollectionEntity>(
                sortBy: [SortDescriptor(\.order)]
            )
            let entities = try modelContext.fetch(descriptor)
            return entities.map { $0.toGameCollection() }
        } catch {
            logger.error("Failed to load collections: \(error)")
            return []
        }
    }

    func save(_ collections: [GameCollection]) {
        do {
            let existing = try modelContext.fetch(FetchDescriptor<CollectionEntity>())
            var existingByID = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

            for (index, collection) in collections.enumerated() {
                let entity: CollectionEntity
                if let found = existingByID.removeValue(forKey: collection.id) {
                    found.name = collection.name
                    found.expanded = collection.expanded
                    found.order = index
                    entity = found
                } else {
                    entity = CollectionEntity(id: collection.id, name: collection.name, expanded: collection.expanded, order: index)
                    modelContext.insert(entity)
                }
                syncGames(of: collection, into: entity)
            }

            for (_, removed) in existingByID {
                modelContext.delete(removed)
            }

            try modelContext.save()
        } catch {
            logger.error("Failed to save collections: \(error)")
        }
    }

    private func syncGames(of collection: GameCollection, into entity: CollectionEntity) {
        var existingByID = Dictionary(uniqueKeysWithValues: entity.games.map { ($0.id, $0) })

        for (gameIndex, gameData) in collection.games.enumerated() {
            if let found = existingByID.removeValue(forKey: gameData.id) {
                found.update(from: gameData, order: gameIndex)
            } else if let gameEntity = GameEntity(from: gameData, order: gameIndex) {
                gameEntity.collection = entity
                entity.games.append(gameEntity)
            }
        }

        for (_, removed) in existingByID {
            modelContext.delete(removed)
        }
    }

    func importGames(from url: URL) async -> [GameData] {
        let pgnGames = await loadGames(url)
        return pgnGames.map { GameData.from($0) }
    }

    private func loadGames(_ url: URL) async -> [PgnGame] {
        await Task.detached(priority: .utility) {
            let pgn = Self.getFileContent(url)
            return PgnParser.parse(pgn)
        }.value
    }

    nonisolated private static func getFileContent(_ url: URL) -> String {
        let path = url.path(percentEncoded: false)
        do {
            var encoding: String.Encoding = .utf8
            return try String(contentsOfFile: path, usedEncoding: &encoding)
        } catch {
            Log.logger("SwiftDataGameCollectionRepository").info("content of path <\(path)> could not be loaded: \(error)")
        }
        return ""
    }
}
