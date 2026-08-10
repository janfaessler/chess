import Foundation

struct GameData: Identifiable, Hashable, Codable {
    let id: UUID
    let headers: [String: String]
    let moves: [MoveData]
    let result: String
    let comment: String?

    init(id: UUID = UUID(), headers: [String: String], moves: [MoveData], result: String, comment: String?) {
        self.id = id
        self.headers = headers
        self.moves = moves
        self.result = result
        self.comment = comment
    }

    func getTitle() -> String {
        guard let white = headers["White"],
              let black = headers["Black"]
        else { return headers["Event"] ?? "???" }
        return "\(white) - \(black)"
    }

    func toPgnGame() -> PgnGame {
        PgnGame(
            headers: headers,
            moves: moves.map { $0.toPgnMove() },
            result: result,
            comment: comment
        )
    }

    static func from(_ pgnGame: PgnGame) -> GameData {
        GameData(
            headers: pgnGame.headers,
            moves: pgnGame.moves.map { MoveData.from($0) },
            result: pgnGame.result,
            comment: pgnGame.comment
        )
    }
}
