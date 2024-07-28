import SwiftUI
import os

public class ControlModel : ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ControlModel")

    private let minControlWidth:CGFloat = 200

    @Published var engineEval:String = ""
    @Published var lines:[EngineLine] = []
    @Published var games:[PgnGame] = []
    
    @Published var game:PgnGame? = nil

    @ObservedObject var board = BoardModel()
    @ObservedObject var moveList = MoveListModel()
    
    private var engine:ChessEngine = ChessEngine()

    init() {
        engine.addEvalListener(updateEval)
        board.addMoveListener(movePlayed)
        moveList.addPositionChangeListener(positionChange)
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
        game = games.first
        openGame()
    }
    
    func openGame() {
        guard let game = game else { return }
        let structure = StructureFactory.create(game)
        moveList.load(structure)
    }
    
    private func loadGames(_ urls:[URL]) async -> [PgnGame] {
        guard let filepath = urls.first else { return [] }
        let pgn = getFileContent(filepath)
        return PgnParser.parse(pgn)
    }
    
    private func updatePosition() {
        guard let newPosition = moveList.getPosition() else { return }
        board.updatePosition(newPosition)
        engine.newPosition(newPosition)
    }
    
    private func movePlayed(_ notation:String) {
        moveList.movePlayed(notation)
        engine.newPosition(board.getPosition())
    }
    
    private func positionChange(_ pos:Position) {
        board.updatePosition(pos)
        engine.newPosition(pos)
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
