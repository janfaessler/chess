/// Abstraction over the analysis engine so `ControlModel` can be driven by the
/// real Stockfish-backed `ChessEngine` in production and by a deterministic
/// stub during UI tests.
@MainActor
protocol EngineProtocol: AnyObject {
    /// Emits the latest evaluation lines whenever the engine reports new results.
    var evalStream: AsyncStream<[EngineLine]> { get }

    /// Analyse the given position, emitting results via ``evalStream``.
    func newPosition(_ position: Position)
}
