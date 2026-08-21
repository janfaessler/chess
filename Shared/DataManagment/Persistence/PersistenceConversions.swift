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

private func decode<T: Decodable>(_ data: Data, as type: T.Type) -> T? {
    do {
        return try JSONDecoder().decode(type, from: data)
    } catch {
        logger.error("Failed to decode \(type): \(error)")
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
        guard let headers = decode(headersData, as: [String: String].self),
              let moves = decode(movesData, as: [MoveData].self)
        else { return nil }
        return GameData(
            id: id,
            headers: headers,
            moves: moves,
            result: result,
            comment: comment
        )
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
