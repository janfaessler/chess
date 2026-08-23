import Foundation
import SwiftChessCore

@MainActor
final class PgnFilesRepository: FileRepository {
    func importGames(from url: URL) async -> [GameData] {
        let pgnGames = await loadGames(url)
        return pgnGames.map { GameData.from($0) }
    }

    private func loadGames(_ url: URL) async -> [PgnGame] {
        await Task.detached(priority: .utility) {
            let pgn = Self.getFileContent(url)
            return PgnParser.parse(pgn)
        }.value
    }

    nonisolated private static func getFileContent(_ url: URL) -> String {
        let path = url.path(percentEncoded: false)
        do {
            var encoding: String.Encoding = .utf8
            return try String(contentsOfFile: path, usedEncoding: &encoding)
        } catch {
            Log.logger("SwiftDataGameCollectionRepository").info("content of path <\(path)> could not be loaded: \(error)")
        }
        return ""
    }
}
