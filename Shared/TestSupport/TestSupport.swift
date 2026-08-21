import Foundation
import SwiftData
import SwiftChessCore

/// Central place for UI-test hooks.
///
/// The production app never sets these launch arguments / environment values,
/// so all behaviour here is inert unless the app is launched by the UI test
/// bundle (which passes `-uiTesting`).
enum TestSupport {

    /// Launch argument that puts the app into a deterministic UI-testing state:
    /// an in-memory store seeded with known data and a stubbed chess engine.
    static let uiTestingArgument = "-uiTesting"

    /// Environment key used to seed the board with a specific position (FEN)
    /// so board-interaction tests (moves, castling, promotion, checkmate, …)
    /// start from a known, reproducible setup.
    static let boardFenEnvironmentKey = "UITEST_BOARD_FEN"

    static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains(uiTestingArgument)
    }

    /// FEN the board should start from, if a test provided one.
    static var boardFen: String? {
        ProcessInfo.processInfo.environment[boardFenEnvironmentKey]
    }

    // MARK: - Seeded data

    /// Collection name used by the seeded UI-testing data.
    static let seededCollectionName = "UITest Collection"

    /// A game containing a mainline, a variation and a comment. Used by the
    /// navigation, move-list and variation tests.
    static let seededGamePgn = """
    [Event "UITest"]
    [White "Alice"]
    [Black "Bob"]

    1. e4 e5 2. Nf3 Nc6 (2... d6 3. d4) 3. Bb5 {Ruy Lopez} a6 *
    """

    /// A second, plain game so the sidebar shows more than one entry.
    static let seededSecondGamePgn = """
    [Event "UITest"]
    [White "Carol"]
    [Black "Dave"]

    1. d4 d5 2. c4 e6 *
    """

    /// Builds an in-memory container seeded with the known UI-testing data.
    @MainActor
    static func makeSeededContainer() -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: CollectionEntity.self, GameEntity.self,
            configurations: configuration
        )
        seed(into: container.mainContext)
        return container
    }

    @MainActor
    private static func seed(into context: ModelContext) {
        let collection = CollectionEntity(
            name: seededCollectionName,
            expanded: true,
            order: 0
        )
        context.insert(collection)

        for (index, pgn) in [seededGamePgn, seededSecondGamePgn].enumerated() {
            guard let pgnGame = PgnParser.parse(pgn).first,
                  let gameEntity = GameEntity(from: GameData.from(pgnGame), order: index) else { continue }
            gameEntity.collection = collection
            collection.games.append(gameEntity)
        }

        try? context.save()
    }
}
