import Foundation

struct RowContainer : Equatable {
    let moveNumber:Int
    var white:MoveContainer
    var black:MoveContainer?
    
    func hasBlackMoved() -> Bool {
        black != nil
    }
}
