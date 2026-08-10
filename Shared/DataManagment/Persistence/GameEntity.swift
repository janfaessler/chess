import Foundation
import SwiftData

@Model
final class GameEntity {
    var id: UUID
    var title: String
    var headersData: Data
    var movesData: Data
    var result: String
    var comment: String?
    var order: Int

    var collection: CollectionEntity?

    init(id: UUID = UUID(), title: String, headersData: Data, movesData: Data, result: String, comment: String?, order: Int) {
        self.id = id
        self.title = title
        self.headersData = headersData
        self.movesData = movesData
        self.result = result
        self.comment = comment
        self.order = order
    }
}
