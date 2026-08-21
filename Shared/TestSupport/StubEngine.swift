import Foundation
import SwiftChessCore

/// Deterministic engine used during UI tests. It emits fixed evaluation lines
/// synchronously so the analysis UI can be asserted on without depending on the
/// real (slow, non-deterministic) Stockfish engine.
@MainActor
final class StubEngine: EngineProtocol {

    let evalStream: AsyncStream<[EngineLine]>
    private let evalContinuation: AsyncStream<[EngineLine]>.Continuation

    init() {
        (evalStream, evalContinuation) = AsyncStream.makeStream(of: [EngineLine].self)
    }

    func newPosition(_ position: Position) {
        evalContinuation.yield([
            EngineLine(id: 1, score: "+0.30", line: "e4, e5, Nf3"),
            EngineLine(id: 2, score: "+0.10", line: "d4, d5, c4"),
            EngineLine(id: 3, score: "-0.20", line: "c4, e5, Nc3")
        ])
    }
}
