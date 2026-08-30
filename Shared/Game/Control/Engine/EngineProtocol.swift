import SwiftChessCore

@MainActor
protocol EngineProtocol: AnyObject {

    var evalStream: AsyncStream<[EngineLine]> { get }

    func prepareForNewGame()
    func newPosition(_ position: Position)

}
