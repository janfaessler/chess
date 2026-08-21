import SwiftChessCore

@MainActor
protocol EngineProtocol: AnyObject {
    
    var evalStream: AsyncStream<[EngineLine]> { get }
    
    func newPosition(_ position: Position)
    
}
