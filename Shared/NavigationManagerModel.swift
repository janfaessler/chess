import Foundation
import os

struct GameSet {
    let id:UUID =  UUID()
    let name:String
    var expanded:Bool
    var games:[PgnGame] = []
}

public class NavigationManagerModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NavigationManagerModel")
    
    @Published var games:[GameSet] = []

    func openFiles(urls: [URL]) async {
        for url in urls {
            let games = await loadGames(url)
            await MainActor.run {
                self.games += [GameSet(name: url.lastPathComponent, expanded: true, games: games)]
            }
        }
    }

    private func loadGames(_ url:URL) async -> [PgnGame] {
        let pgn = getFileContent(url)
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
