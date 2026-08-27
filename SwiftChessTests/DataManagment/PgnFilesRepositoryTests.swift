import Testing
import Foundation
@testable import SwiftChess

@MainActor
struct PgnFilesRepositoryTests {

    private static let samplePgn = """
    [Event "Test"]
    [White "Alice"]
    [Black "Bob"]

    1. e4 e5 2. Nf3 Nc6 *
    """

    private func writeTempFile(_ content: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("pgn")
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    @Test func testImportGames_validPgn_returnsOneGame() async throws {
        let url = try writeTempFile(Self.samplePgn)
        defer { try? FileManager.default.removeItem(at: url) }
        let repo = PgnFilesRepository()
        let games = try await repo.importGames(from: url)
        #expect(games.count == 1)
    }

    @Test func testImportGames_validPgn_hasCorrectHeaders() async throws {
        let url = try writeTempFile(Self.samplePgn)
        defer { try? FileManager.default.removeItem(at: url) }
        let repo = PgnFilesRepository()
        let games = try await repo.importGames(from: url)
        let game = try #require(games.first)
        #expect(game.headers["White"] == "Alice")
        #expect(game.headers["Black"] == "Bob")
    }

    @Test func testImportGames_validPgn_hasMoves() async throws {
        let url = try writeTempFile(Self.samplePgn)
        defer { try? FileManager.default.removeItem(at: url) }
        let repo = PgnFilesRepository()
        let games = try await repo.importGames(from: url)
        let game = try #require(games.first)
        #expect(!game.moves.isEmpty)
    }

    @Test func testImportGames_nonexistentFile_throws() async {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("does_not_exist_\(UUID().uuidString).pgn")
        let repo = PgnFilesRepository()
        await #expect(throws: PgnFileError.self) {
            _ = try await repo.importGames(from: url)
        }
    }

    @Test func testImportGames_emptyPgn_returnsNoGames() async throws {
        let url = try writeTempFile("")
        defer { try? FileManager.default.removeItem(at: url) }
        let repo = PgnFilesRepository()
        let games = try await repo.importGames(from: url)
        #expect(games.isEmpty)
    }
}
