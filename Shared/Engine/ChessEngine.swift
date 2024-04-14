import Foundation
import ChessKitEngine

final class ChessEngine {
    
    typealias EvalNotification = ([EngineLine]) -> ()
    private var evalNotifcations:[EvalNotification] = []
    
    private let lineNumbers = 3
    private let engine:Engine
    private var lines:[EngineLine] = []
    private var pos:Position = Fen.loadStartingPosition()

    init() {
        engine = Engine(type: .stockfish)
        engine.receiveResponse = handleEngineResponse
        engine.start()
        engine.send(command: .setoption(id: "MultiPV", value: "\(lineNumbers)"))
        for i in 0..<lineNumbers {
            lines = [EngineLine(id: i, score: "-", line: "")]
        }
    }
    
    public func newPosition(_ pos:Position) {
        guard engine.isRunning else { return }
        self.pos = pos
        engine.send(command: .stop)
        engine.send(command: .position(.fen(FenBuilder.create(pos))))
        engine.send(command: .go(depth: 15))
    }
    
    public func addEvalListener(_ listener:@escaping EvalNotification) {
        evalNotifcations += [listener]
    }
        
    private func handleEngineResponse(_ response:EngineResponse) {
        switch response {
        case let .info(info):
            guard let lineNumber = info.multipv  else {return}
            
            let line = EngineLine(id: lineNumber,
                                  score: getScore(info),
                                  line: getLine(info.pv ??  []))
            
            lines.removeAll(where: { $0.id == lineNumber })
            lines += [line]
            notifyEval(lines.sorted(by: { $0.id < $1.id }))
        default:
            break
        }
    }
    
    private func notifyEval(_ lines:[EngineLine]) {
        for event in evalNotifcations {
            event(lines)
        }
    }
    
    private func getLine(_ engineline:[String]) -> String {
        var moveNotations:[String]  = []
        
        var tempPos = pos
        for lan in engineline {
            guard let move = LanParser.parse(lan: lan, position: pos) else {
                return moveNotations.joined(separator: ", ")
            }
            let isCapture = tempPos.isNotEmpty(atRow: move.row, atFile: move.file)
            tempPos = tempPos.createWithMove(move)
            let notation = getNotation(move:move, isCapture:isCapture)
            moveNotations += [notation]
        }
        return moveNotations.joined(separator: ", ")
    }
    
    private func getScore(_ info:EngineResponse.Info) -> String {
        if info.score?.cp != nil {
            return "\(String(format:"%2.2f", CGFloat(info.score!.cp! / 100)))"
        } else if info.score?.mate != nil {
            return  "M\(info.score!.mate ?? 0)"
        }
        return ""
    }
    
    private func getNotation(move:Move, isCapture:Bool) -> String {
        if isCapture {
            return (move.piece.getType() == .pawn ? move.piece.getField().getFileName() : move.piece.ident()) + "x" + move.getFieldInfo()
        }
        return move.info()

    }
}



