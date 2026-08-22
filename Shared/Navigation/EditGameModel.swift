import Foundation

struct HeaderEntry: Identifiable {
    var id = UUID()
    var key: String
    var value: String
}

@Observable
@MainActor
class EditGameModel {

    var white: String
    var black: String
    var event: String
    var site: String
    var date: Date
    var round: String
    var extraHeaders: [HeaderEntry]

    private let game: GameData
    private let navigationModel: NavigationManagerModel
    private let targetCollection: GameCollection?

    var isNew: Bool { targetCollection != nil }
    var title: String { isNew ? "Add Game" : "Edit Game" }

    static let standardKeys = ["White", "Black", "Event", "Site", "Date", "Round", "Result"]

    private static let pgnDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()

    init(game: GameData, navigationModel: NavigationManagerModel, targetCollection: GameCollection? = nil) {
        self.game = game
        self.navigationModel = navigationModel
        self.targetCollection = targetCollection
        white = game.headers["White"] ?? ""
        black = game.headers["Black"] ?? ""
        event = game.headers["Event"] ?? ""
        site = game.headers["Site"] ?? ""
        round = game.headers["Round"] ?? ""
        date = Self.pgnDateFormatter.date(from: game.headers["Date"] ?? "") ?? Date()
        extraHeaders = game.headers
            .filter { !Self.standardKeys.contains($0.key) }
            .sorted { $0.key < $1.key }
            .map { HeaderEntry(key: $0.key, value: $0.value) }
    }

    func addTag() {
        extraHeaders.append(HeaderEntry(key: "", value: ""))
    }

    func removeTag(_ entry: HeaderEntry) {
        extraHeaders.removeAll { $0.id == entry.id }
    }

    func save() -> GameData? {
        var updated = game.headers
        setHeader(&updated, "White", white)
        setHeader(&updated, "Black", black)
        setHeader(&updated, "Event", event)
        setHeader(&updated, "Site", site)
        updated["Date"] = Self.pgnDateFormatter.string(from: date)
        setHeader(&updated, "Round", round)
        for entry in extraHeaders where !entry.key.isEmpty {
            setHeader(&updated, entry.key, entry.value)
        }
        let keptKeys = Set(extraHeaders.map(\.key))
        for key in game.headers.keys where !Self.standardKeys.contains(key) && !keptKeys.contains(key) {
            updated.removeValue(forKey: key)
        }
        if let collection = targetCollection {
            let newGame = GameData(headers: updated, moves: game.moves, result: game.result, comment: game.comment)
            return navigationModel.addGame(newGame, to: collection)
        }
        return navigationModel.updateGame(game, headers: updated, result: game.result)
    }

    private func setHeader(_ headers: inout [String: String], _ key: String, _ value: String) {
        if value.isEmpty {
            headers.removeValue(forKey: key)
        } else {
            headers[key] = value
        }
    }
}
