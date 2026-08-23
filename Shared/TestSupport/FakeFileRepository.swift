import Foundation

@MainActor
final class FakeFileRepository: FileRepository {

    var importResult: [GameData]

    init(importResult: [GameData] = []) {
        self.importResult = importResult
    }

    func importGames(from url: URL) async throws -> [GameData] {
        importResult
    }
}
