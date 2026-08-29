import Foundation
import SwiftChessCore

enum PgnFileError: Error {
    case importFailed(Error)
}

final class PgnFilesRepository: FileRepository {
    func importGames(from url: URL) async throws -> [GameData] {
        let pgnGames = try await loadGames(url)
        return pgnGames.map { GameData.from($0) }
    }

    private func loadGames(_ url: URL) async throws -> [PgnGame] {
        try await Task(name: "PgnFilesRepository.loadGames") {
            let pgn = try PgnFilesRepository.getFileContent(url)
            return PgnParser.parse(pgn)
        }.value
    }

    private static func getFileContent(_ url: URL) throws -> String {
        let path = url.path(percentEncoded: false)
        do {
            var encoding: String.Encoding = .utf8
            return try String(contentsOfFile: path, usedEncoding: &encoding)
        } catch {
            Log.logger("SwiftDataGameCollectionRepository").info("content of path <\(path)> could not be loaded: \(error)")
            throw PgnFileError.importFailed(error)
        }
    }
}
