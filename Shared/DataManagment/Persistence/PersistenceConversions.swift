import Foundation

private func encode<T: Encodable>(_ value: T, for gameId: UUID) throws -> Data {
    do {
        return try JSONEncoder().encode(value)
    } catch {
        throw RepositoryError.corruptedData(gameId: gameId, reason: "encoding failed: \(error.localizedDescription)")
    }
}

private func decode<T: Decodable>(_ data: Data, as type: T.Type, for gameId: UUID) throws -> T {
    do {
        return try JSONDecoder().decode(type, from: data)
    } catch {
        throw RepositoryError.corruptedData(gameId: gameId, reason: "decoding failed: \(error.localizedDescription)")
    }
}

extension GameEntity {
    convenience init(from gameData: GameData, order: Int) throws {
        self.init(
            id: gameData.id,
            title: gameData.getTitle(),
            headersData: try encode(gameData.headers, for: gameData.id),
            movesData: try encode(gameData.moves, for: gameData.id),
            result: gameData.result,
            comment: gameData.comment,
            order: order
        )
    }

    func update(from gameData: GameData, order: Int) throws {
        self.headersData = try encode(gameData.headers, for: gameData.id)
        self.movesData = try encode(gameData.moves, for: gameData.id)
        title = gameData.getTitle()
        result = gameData.result
        comment = gameData.comment
        self.order = order
    }

    func toGameData() throws -> GameData {
        GameData(
            id: id,
            headers: try decode(headersData, as: [String: String].self, for: id),
            moves: try decode(movesData, as: [MoveData].self, for: id),
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
