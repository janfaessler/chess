import Foundation
import SwiftData
import SwiftChessCore

enum RepositoryError: Error {
    case persistenceFailed(Error),
         loadCollectionFailed(Error)
}

@MainActor
final class SwiftDataGameCollectionRepository: GameCollectionRepository {

    private let logger = Log.logger("SwiftDataGameCollectionRepository")

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func load() throws -> [GameCollection] {
        do {
            let descriptor = FetchDescriptor<CollectionEntity>(
                sortBy: [SortDescriptor(\.order)]
            )
            let entities = try modelContext.fetch(descriptor)
            return try entities.map { try $0.toGameCollection() }
        } catch {
            logger.error("Failed to load collections: \(error)")
            throw RepositoryError.loadCollectionFailed(error)
        }
    }

    func save(_ collections: [GameCollection]) throws {
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
                try syncGames(of: collection, into: entity)
            }

            for (_, removed) in existingByID {
                modelContext.delete(removed)
            }

            try modelContext.save()
        } catch {
            logger.error("Failed to save collections: \(error)")
            throw RepositoryError.persistenceFailed(error)
        }
    }

    private func syncGames(of collection: GameCollection, into entity: CollectionEntity) throws {
        var existingByID = Dictionary(uniqueKeysWithValues: entity.games.map { ($0.id, $0) })

        for (gameIndex, gameData) in collection.games.enumerated() {
            if let found = existingByID.removeValue(forKey: gameData.id) {
                try found.update(from: gameData, order: gameIndex)
            } else {
                let gameEntity = try GameEntity(from: gameData, order: gameIndex)
                gameEntity.collection = entity
                entity.games.append(gameEntity)
            }
        }

        for (_, removed) in existingByID {
            modelContext.delete(removed)
        }
    }
}
