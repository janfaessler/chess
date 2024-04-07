import Foundation
import ChessKitEngine
import os

public class ControlModel : ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ControlModel")

    @Published var currentMove:Int = 0
    @Published var board:BoardModel
    @Published var moves:[String] = []
    @Published var engineEval:String = ""
    let engine:Engine
    
    init() {
        board = BoardModel()
        engine = Engine(type: .stockfish)

        board.addMoveListener(movePlayed)
        engine.receiveResponse = engineResponse
        engine.start()
    }

    func getMoves() -> [String] {
        return moves
    }
    
    func start() {
        currentMove = 0
        updatePosition()
    }
    
    func back() {
        if currentMove > 0 {
            currentMove -= 1
            updatePosition()
        }
    }
    
    func forward() {
        if currentMove < moves.count {
            currentMove += 1
            updatePosition()
        }
    }
    
    func end() {
        currentMove = moves.count
        updatePosition()
    }
    
    func goToMove(_ index:Int) {
        currentMove = index
        updatePosition()
    }
    
    private func updatePosition() {
        guard let newPosition = Pgn.loadPosition(Array(moves[0..<currentMove])) else { return }
        board.updatePosition(newPosition)
    }
    
    private func movePlayed(_ move:String) {
        moves += [board.getMoveLog().last!]
        currentMove += 1
        
        // check that engine is running before sending commands
        guard engine.isRunning else { return }

        // stop any current engine processing
        engine.send(command: .stop)

        // set engine position to standard starting chess position
        engine.send(command: .position(.fen(FenBuilder.create(board.getPosition()))))

        // start engine analysis with maximum depth of 15
        engine.send(command: .go(depth: 15))
    }
    
    private func engineResponse(_ response:EngineResponse) {
        switch response {
        case let .info(info):
            guard let score = info.score?.cp else { return }
            guard let moves = info.pv else { return }
            
            var moveNotations:[String]  = []
            var pos = board.getPosition()
            
            for lan in moves {
                guard let move = LanParser.parse(lan: lan, position: pos) else {return }
                let isCapture = pos.isNotEmpty(atRow: move.row, atFile: move.file)
                let piece = move.getPiece()
                pos = pos.createWithMove(move)
                let notation = (piece.getType() == .pawn ? (isCapture ? piece.getField().getFileName() : "") : piece.ident()) + (isCapture ? "x" : "") + move.getFieldInfo()
                
                moveNotations += [notation]
            }
            
            engineEval = "\(String(format: "%2.3f",  score / 100 )) \(moveNotations.joined(separator: ", "))"

        default:
            break
        }
       // logger.info("\(response.rawValue)")
    }
}
