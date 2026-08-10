import Foundation
import SwiftData

@Model
final class CollectionEntity {
    var id: UUID
    var name: String
    var expanded: Bool
    var order: Int

    @Relationship(deleteRule: .cascade, inverse: \GameEntity.collection)
    var games: [GameEntity]

    init(id: UUID = UUID(), name: String, expanded: Bool, order: Int, games: [GameEntity] = []) {
        self.id = id
        self.name = name
        self.expanded = expanded
        self.order = order
        self.games = games
    }
}
