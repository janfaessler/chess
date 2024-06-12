import Foundation

public struct RowContainer : Equatable {
    public let moveNumber:Int
    public var white:MoveContainer
    public var black:MoveContainer?
    
    func hasBlackMoved() -> Bool {
        black != nil
    }
}
