import SwiftUI
import os

public class ControlModel : ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ControlModel")

    private let minControlWidth:CGFloat = 200

    @Published var engineEval:String = ""
    @Published var lines:[EngineLine] = []
    @Published var games:[PgnGame] = []

    @ObservedObject var board = BoardModel()
    @ObservedObject var moves = MoveListModel()
    
    private var engine:ChessEngine = ChessEngine()

    init() {
        engine.addEvalListener(updateEval)
        board.addMoveListener(movePlayed)
        moves.addPositionChangeListener(positionChange)
    }
    
    var moveListColumns:[GridItem] {
        [GridItem(.fixed(20)), GridItem(.flexible()), GridItem(.flexible())]
    }
    
    var navigationbuttonSize:CGSize {
        CGSize(width: minControlWidth / 4, height: 30)
    }
    
    func getBoardSize(_ geo:GeometryProxy) -> CGFloat {
        return min(geo.size.width - minControlWidth, geo.size.height)
    }
    
    func openFiles(urls: [URL]) async {
        games = await loadGames(urls)
        guard let firstGame = games.first else { return }
        openGame(firstGame)
    }
    
    func openGame(_ game: PgnGame) {
        moves.updateMoveList(ContainerFactory.create(game))
    }
    
    private func loadGames(_ urls:[URL]) async -> [PgnGame] {
        guard let filepath = urls.first else { return [] }
        let pgn = getFileContent(filepath)
        return PgnParser.parse(pgn)
    }
    
    private func updatePosition() {
        guard let newPosition = moves.getPosition() else { return }
        board.updatePosition(newPosition)
        engine.newPosition(newPosition)
    }
    
    private func movePlayed(_ notation:String) {
        moves.movePlayed(notation)
        engine.newPosition(board.getPosition())
    }
    
    private func positionChange(_ pos:Position) {
        engine.newPosition(pos)
        board.updatePosition(pos)
    }
    
    private func updateEval(_ eval:[EngineLine]) {
        self.lines.removeAll()
        self.lines.append(contentsOf: eval)
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
