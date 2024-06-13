import Foundation

public class RowContainer : ObservableObject, Equatable {
    public let moveNumber:Int
    public var white:MoveContainer?
    public var black:MoveContainer?
    
    init(moveNumber: Int, white: MoveContainer? = nil, black: MoveContainer? = nil) {
        self.moveNumber = moveNumber
        self.white = white
        self.black = black
    }
    
    func hasWhiteMoved() -> Bool {
        white != nil
    }
    
    func hasBlackMoved() -> Bool {
        black != nil
    }
    
    func hasWhiteVariations() -> Bool {
        white?.variations.count ?? 0 > 0
    }
    
    func hasBlackVariations() -> Bool {
        black?.variations.count ?? 0 > 0
    }
    
    public static func == (lhs: RowContainer, rhs: RowContainer) -> Bool {
        lhs.moveNumber == rhs.moveNumber && lhs.white?.id == rhs.white?.id && lhs.black?.id == rhs.black?.id
    }
}
