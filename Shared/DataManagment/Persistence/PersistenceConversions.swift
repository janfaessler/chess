import Foundation

private let logger = Log.logger("PersistenceConversions")

private func encode<T: Encodable>(_ value: T, field: String) -> Data? {
    do {
        return try JSONEncoder().encode(value)
    } catch {
        logger.error("Failed to encode \(field): \(error)")
        return nil
    }
}

extension GameEntity {
    convenience init?(from gameData: GameData, order: Int) {
        guard let headersData = encode(gameData.headers, field: "headers"),
              let movesData = encode(gameData.moves, field: "moves")
        else { return nil }

        self.init(
            id: gameData.id,
            title: gameData.getTitle(),
            headersData: headersData,
            movesData: movesData,
            result: gameData.result,
            comment: gameData.comment,
            order: order
        )
    }

    func update(from gameData: GameData, order: Int) {
        guard let headersData = encode(gameData.headers, field: "headers"),
              let movesData = encode(gameData.moves, field: "moves")
        else { return }
        self.headersData = headersData
        self.movesData = movesData
        title = gameData.getTitle()
        result = gameData.result
        comment = gameData.comment
        self.order = order
    }

    func toGameData() -> GameData? {
        let decoder = JSONDecoder()
        do {
            let headers = try decoder.decode([String: String].self, from: headersData)
            let moves = try decoder.decode([MoveData].self, from: movesData)
            return GameData(
                id: id,
                headers: headers,
                moves: moves,
                result: result,
                comment: comment
            )
        } catch {
            logger.error("Failed to decode game \(self.id): \(error)")
            return nil
        }
    }
}

extension CollectionEntity {
    func toGameCollection() -> GameCollection {
        let sortedGames = games.sorted { $0.order < $1.order }
        let gameDataArray = sortedGames.compactMap { $0.toGameData() }
        return GameCollection(
            id: id,
            name: name,
            expanded: expanded,
            games: gameDataArray
        )
    }
}
