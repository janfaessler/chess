import Foundation

public class MovePairModel : ObservableObject, Equatable {
    public let moveNumber:Int
    public var white:MoveModel?
    public var black:MoveModel?
    
    private init(moveNumber: Int, white: MoveModel? = nil, black: MoveModel? = nil) {
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
    
    public static func create(_ container: MoveModel, moveNumber:Int = 1)  -> MovePairModel {
        var rowContainer:MovePairModel
        if container.color == .white {
            rowContainer = MovePairModel(moveNumber: moveNumber, white: container)
        } else {
            rowContainer = MovePairModel(moveNumber: moveNumber, black: container)
        }
        return rowContainer
    }
    
    public static func create(moveNumber:Int) -> MovePairModel {
        return MovePairModel(moveNumber: moveNumber)
    }
}
