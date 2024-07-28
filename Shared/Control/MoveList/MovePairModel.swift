import Foundation

public class MovePairModel : ObservableObject, Equatable {
    public let moveNumber:Int
    public var white:MoveModel?
    public var black:MoveModel?
    
    init(moveNumber: Int, white: MoveModel? = nil, black: MoveModel? = nil) {
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
        white?.getVariations().count ?? 0 > 0
    }
    
    func hasBlackVariations() -> Bool {
        black?.getVariations().count ?? 0 > 0
    }
    
    public static func == (lhs: MovePairModel, rhs: MovePairModel) -> Bool {
        lhs.moveNumber == rhs.moveNumber && lhs.white?.id == rhs.white?.id && lhs.black?.id == rhs.black?.id
    }
}
