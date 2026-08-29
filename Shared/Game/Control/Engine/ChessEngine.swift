import Foundation
import ChessKitEngine
import SwiftChessCore

@Observable
final class ChessEngine: EngineProtocol {

    private let logger = Log.logger("ChessEngine")

    let evalStream: AsyncStream<[EngineLine]>
    private let evalContinuation: AsyncStream<[EngineLine]>.Continuation

    private static let engine = Engine(type: .stockfish)
    private let settings: EngineSettings
    private var lines: [EngineLine] = []
    private var pos: Position = try! PositionFactory.startingPosition()

    private var configurationTask: Task<Void, Never>?
    private var responseTask: Task<Void, Never>?
    private var analysisTask: Task<Void, Never>?
    private var settingsTask: Task<Void, Never>?
    private let debounceDelay = Duration.seconds(1)

    init(settings: EngineSettings = EngineSettings()) {
        (evalStream, evalContinuation) = AsyncStream.makeStream(of: [EngineLine].self)
        self.settings = settings
    }

    private func startIfNeeded() {
        guard self.configurationTask == nil else { return }
        let engine = ChessEngine.engine
        let coreCount = settings.coreCount
        let lineCount = settings.lineCount
        let debug = settings.debug

        self.configurationTask = Task(name: "ChessEngine.configuration") {
            guard await !engine.isRunning else { return }
            await engine.set(loggingEnabled: debug)
            await engine.start(coreCount: coreCount, multipv: lineCount)
            while await !engine.isRunning, !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(50))
            }
            guard !Task.isCancelled else { return }
            guard let evalFile = Bundle.main.url(forResource: "nn-1111cefa1111", withExtension: "nnue") else {
                return
            }
            await engine.send(command: .setoption(id: "EvalFile", value: evalFile.absoluteURL.path()))
            guard let evalFile = Bundle.main.url(forResource: "nn-37f18f62d772", withExtension: "nnue") else {
                return
            }
            await engine.send(command: .setoption(id: "EvalFileSmall", value: evalFile.absoluteURL.path()))
        }

        responseTask = Task(name: "ChessEngine.responseStream") { [weak self] in
            await self?.configurationTask?.value
            guard let stream = await engine.responseStream else { return }
            for await response in stream {
                guard !Task.isCancelled, let self else { return }
                self.handleEngineResponse(response)
            }
        }

        let settings = self.settings
        settingsTask = Task(name: "ChessEngine.settings") { [weak self] in
            await self?.configurationTask?.value
            for await _ in settings.changes {
                guard !Task.isCancelled, let self else { return }
                guard await engine.isRunning else { continue }
                self.newPosition(self.pos)
            }
        }
    }

    isolated deinit {
        configurationTask?.cancel()
        responseTask?.cancel()
        analysisTask?.cancel()
        settingsTask?.cancel()
        evalContinuation.finish()
    }

    public func newPosition(_ pos: Position) {
        startIfNeeded()
        self.pos = pos
        let fen = FenBuilder.create(pos)
        let depth = settings.depth
        let coreCount = settings.coreCount
        let lineCount = settings.lineCount
        let debug = settings.debug
        let engine = ChessEngine.engine

        analysisTask?.cancel()
        analysisTask = Task(name: "ChessEngine.analyze(\(fen)") { [configurationTask, debounceDelay] in
            await configurationTask?.value
            guard await engine.isRunning else { return }
            await engine.send(command: .stop)

            await engine.set(loggingEnabled: debug)
            await engine.send(command: .setoption(id: "Threads", value: "\(max(coreCount - 1, 1))"))
            await engine.send(command: .setoption(id: "MultiPV", value: "\(lineCount)"))

            try? await Task.sleep(for: debounceDelay)
            guard !Task.isCancelled else { return }

            await engine.send(command: .position(.fen(fen)))
            await engine.send(command: .go(depth: depth))
        }
    }

    private func handleEngineResponse(_ response: EngineResponse) {
        switch response {
        case let .info(info):
            guard let lineNumber = info.multipv else { return }

            let line = EngineLine(id: lineNumber,
                                  score: getScore(info),
                                  line: getLine(info.pv ?? []))

            let newLines = lines.filter { $0.id != lineNumber } + [line]
            lines = newLines.sorted(by: { $0.id < $1.id })
            evalContinuation.yield(lines)
        default:
            break
        }
    }

    private func getLine(_ engineline: [String]) -> String {
        var moveNotations: [String] = []
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

    private func getScore(_ info: EngineResponse.Info) -> String {
        if let cp = info.score?.cp {
            return String(format: "%2.2f", CGFloat(cp) / 100)
        } else if let mate = info.score?.mate {
            return "M\(mate)"
        }
        return ""
    }
}
