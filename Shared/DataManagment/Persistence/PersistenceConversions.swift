import Foundation

extension GameEntity {
    convenience init(from gameData: GameData, order: Int) {
        let encoder = JSONEncoder()
        let headersData = (try? encoder.encode(gameData.headers)) ?? Data()
        let movesData = (try? encoder.encode(gameData.moves)) ?? Data()

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
        let encoder = JSONEncoder()
        headersData = (try? encoder.encode(gameData.headers)) ?? Data()
        movesData = (try? encoder.encode(gameData.moves)) ?? Data()
        title = gameData.getTitle()
        result = gameData.result
        comment = gameData.comment
        self.order = order
    }

    func toGameData() -> GameData? {
        let decoder = JSONDecoder()
        guard let headers = try? decoder.decode([String: String].self, from: headersData),
              let moves = try? decoder.decode([MoveData].self, from: movesData)
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
