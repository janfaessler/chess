import Foundation
import os

public class NavigationManagerModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NavigationManagerModel")
    
    @Published var games:[PgnGame] = []

    func openFiles(urls: [URL]) async {
        let games = await loadGames(urls)
        await MainActor.run {
            self.games = games
        }
    }

    private func loadGames(_ urls:[URL]) async -> [PgnGame] {
        guard let filepath = urls.first else { return [] }
        let pgn = getFileContent(filepath)
        return PgnParser.parse(pgn)
    }
    
    
    private func getFileContent(_ url:URL) -> String {
        let path = url.path(percentEncoded: false)
        do {
            var encoding:String.Encoding = String.Encoding.utf8
            return try String(contentsOfFile: path, usedEncoding: &encoding)
        } catch {
            logger.info("content of path <\(path)> could not be loaded: \(error)")
        }
        return ""
    }
}
