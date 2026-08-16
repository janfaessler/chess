import Foundation
import ChessKitEngine
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@Observable
@MainActor
final class ChessEngine: EngineProtocol {

    private let logger = Log.logger("ChessEngine")

    let evalStream: AsyncStream<[EngineLine]>
    private let evalContinuation: AsyncStream<[EngineLine]>.Continuation

    private let lineNumbers = 3
    private let engine:Engine
    private var lines:[EngineLine] = []
    private var pos:Position = PositionFactory.startingPosition()

    private var responseTask:Task<Void, Never>?
    private var analysisTask:Task<Void, Never>?
    private let debounceDelay = Duration.seconds(1)

    init() {
        (evalStream, evalContinuation) = AsyncStream.makeStream(of: [EngineLine].self)
        engine = Engine(type: .stockfish)

        guard let evalFilePath = materializeEvalFile("EvalFile", "nn-1111cefa1111.nnue") else { return }
        guard let evalFileSmallPath = materializeEvalFile("EvalFileSmall", "nn-37f18f62d772.nnue") else { return }

        let engine = engine
        let multipv = lineNumbers
        responseTask = Task { [weak self] in
            await engine.set(loggingEnabled: true)
            await engine.start(coreCount: 2, multipv: multipv)
            await engine.send(command: .setoption(id: "EvalFile", value: evalFilePath))
            await engine.send(command: .setoption(id: "EvalFileSmall", value: evalFileSmallPath))


            guard let stream = await engine.responseStream else { return }
            for await response in stream {
                self?.handleEngineResponse(response)
            }
        }
    }

    isolated deinit {
        responseTask?.cancel()
        analysisTask?.cancel()
        evalContinuation.finish()
    }

    public func newPosition(_ pos:Position) {
        self.pos = pos
        let fen = FenBuilder.create(pos)

        analysisTask?.cancel()
        analysisTask = Task { [engine, debounceDelay] in
            guard await engine.isRunning else { return }
            await engine.send(command: .stop)
            
            try? await Task.sleep(for: debounceDelay)
            guard !Task.isCancelled else { return }

            await engine.send(command: .position(.fen(fen)))
            await engine.send(command: .go(depth: 15))
            await engine.start()
        }
    }

    private func handleEngineResponse(_ response:EngineResponse) {
        switch response {
        case let .info(info):
            guard let lineNumber = info.multipv  else {return}

            let line = EngineLine(id: lineNumber,
                                  score: getScore(info),
                                  line: getLine(info.pv ??  []))

            let newLines = lines.filter { $0.id != lineNumber } + [line]
            lines = newLines.sorted(by: { $0.id < $1.id })
            evalContinuation.yield(lines)
        default:
            break
        }
    }

    private func getLine(_ engineline:[String]) -> String {
        var moveNotations:[String]  = []
        var tempPos = pos
        for lan in engineline {
            guard let move = LanParser.parse(lan: lan, position: tempPos) else {
                return moveNotations.joined(separator: ", ")
            }
            let notation = NotationFactory.generate(move, position: tempPos)
            tempPos = tempPos.applying(move)
            moveNotations += [notation]
        }
        return moveNotations.joined(separator: ", ")
    }

    private func materializeEvalFile(_ asset:String, _ filename:String) -> String? {
        guard let asset = NSDataAsset(name: asset) else {
            return nil
        }

        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        guard let destination = cachesDirectory?.appendingPathComponent(filename) else {
            return nil
        }

        do {
            if !FileManager.default.fileExists(atPath: destination.path) {
                try asset.data.write(to: destination)
            }
        } catch {
            return nil
        }

        return destination.path(percentEncoded: false)
    }

    private func getScore(_ info: EngineResponse.Info) -> String {
        if let cp = info.score?.cp {
            return String(format: "%2.2f", CGFloat(cp) / 100)
        } else if let mate = info.score?.mate {
            return "M\(mate)"
        }
        return ""
    }
}
