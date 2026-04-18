import Foundation
import os

@Observable
public class NavigationManagerModel {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NavigationManagerModel")
    
    var collections: [GameCollection] = []

    func openFiles(urls: [URL]) async {
        for url in urls {
            let games = await loadGames(url)
            await MainActor.run {
                self.collections += [GameCollection(name: url.lastPathComponent, expanded: true, games: games)]
            }
        }
    }

    private func loadGames(_ url: URL) async -> [PgnGame] {
        let pgn = getFileContent(url)
        return PgnParser.parse(pgn)
    }
    
    private func getFileContent(_ url: URL) -> String {
        let path = url.path(percentEncoded: false)
        do {
            var encoding: String.Encoding = String.Encoding.utf8
            return try String(contentsOfFile: path, usedEncoding: &encoding)
        } catch {
            self.logger.info("content of path <\(path)> could not be loaded: \(error)")
        }
        return ""
    }
}
