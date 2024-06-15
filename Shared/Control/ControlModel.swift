import SwiftUI
import os

public class ControlModel : ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ControlModel")

    private let minControlWidth:CGFloat = 200

    @Published var engineEval:String = ""
    @Published var lines:[EngineLine] = []
    
    @ObservedObject var board = BoardModel()
    @ObservedObject var moves = MoveListModel()
    
    private var engine:ChessEngine = ChessEngine()

    init() {
        engine.addEvalListener(updateEval)
        board.addMoveListener(movePlayed)
        moves.addPositionChangeListener(positionChange)
        loadPgnPosition()
    }
    
    private func loadPgnPosition() {
        if let filepath = Bundle.main.path(forResource: "carlsen-magnus_vs_caruana-fabiano_07-jun-2024", ofType: "pgn") {
            do {
                let contents = try String(contentsOfFile: filepath)
                let moves = Pgn.loadMoves(contents)
                for move in moves {
                    movePlayed(move)
                }
                logger.info("\(contents)")
            } catch {
                logger.info("contents could not be loaded")

                // contents could not be loaded
            }
        } else {
            // example.txt not found!
            logger.info("not found!")

        }
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
    
    private func updatePosition() {
        guard let newPosition = moves.getPosition() else { return }
        board.updatePosition(newPosition)
        engine.newPosition(newPosition)
    }
    
    private func movePlayed(_ move:Move) {
        moves.movePlayed(move)
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
}
