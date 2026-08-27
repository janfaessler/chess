import Foundation

private func encode<T: Encodable>(_ value: T) throws -> Data {
    try JSONEncoder().encode(value)
}

private func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
    try JSONDecoder().decode(type, from: data)
}

extension GameEntity {
    convenience init(from gameData: GameData, order: Int) throws {
        self.init(
            id: gameData.id,
            title: gameData.getTitle(),
            headersData: try encode(gameData.headers),
            movesData: try encode(gameData.moves),
            result: gameData.result,
            comment: gameData.comment,
            order: order
        )
    }

    func update(from gameData: GameData, order: Int) throws {
        self.headersData = try encode(gameData.headers)
        self.movesData = try encode(gameData.moves)
        title = gameData.getTitle()
        result = gameData.result
        comment = gameData.comment
        self.order = order
    }

    func toGameData() throws -> GameData {
        GameData(
            id: id,
            headers: try decode(headersData, as: [String: String].self),
            moves: try decode(movesData, as: [MoveData].self),
            result: result,
            comment: comment
        )
    }
}

extension CollectionEntity {
    func toGameCollection() -> GameCollection {
        let logger = Log.logger("CollectionEntity")
        let sortedGames = games.sorted { $0.order < $1.order }
        let gameDataArray = sortedGames.compactMap { game -> GameData? in
            do {
                return try game.toGameData()
            } catch {
                logger.warning("Skipping corrupted game \(game.id): \(error)")
                return nil
            }
        }
        return GameCollection(
            id: id,
            name: name,
            expanded: expanded,
            games: gameDataArray
        )
    }
}
