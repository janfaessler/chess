import Foundation

@Observable
@MainActor
final class EngineSettings {

    static let shared = EngineSettings()

    static let defaultCoreCount = 2
    static let defaultLineCount = 3
    static let defaultDepth = 15
    static let defaultDebug = false

    let changes: AsyncStream<Void>
    private let changesContinuation: AsyncStream<Void>.Continuation

    var coreCount: Int = UserDefaults.standard.integer(forKey: "engine.coreCount").nonZeroOr(defaultCoreCount) {
        didSet {
            UserDefaults.standard.set(coreCount, forKey: "engine.coreCount")
            changesContinuation.yield()
        }
    }

    var lineCount: Int = UserDefaults.standard.integer(forKey: "engine.lineCount").nonZeroOr(defaultLineCount) {
        didSet {
            UserDefaults.standard.set(lineCount, forKey: "engine.lineCount")
            changesContinuation.yield()
        }
    }

    var depth: Int = UserDefaults.standard.integer(forKey: "engine.depth").nonZeroOr(defaultDepth) {
        didSet {
            UserDefaults.standard.set(depth, forKey: "engine.depth")
            changesContinuation.yield()
        }
    }

    var debug: Bool = UserDefaults.standard.object(forKey: "engine.debug") as? Bool ?? defaultDebug {
        didSet {
            UserDefaults.standard.set(debug, forKey: "engine.debug")
            changesContinuation.yield()
        }
    }

    private init() {
        (changes, changesContinuation) = AsyncStream.makeStream(of: Void.self)
    }
}

private extension Int {
    func nonZeroOr(_ fallback: Int) -> Int {
        self == 0 ? fallback : self
    }
}
