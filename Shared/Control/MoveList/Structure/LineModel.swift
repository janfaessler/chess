import Foundation

public class LineModel {
    private var line:[MovePairModel]
    
    public init(_ line: [MovePairModel] = []) {
        self.line = line
    }
    
    public var first:MoveModel {
        guard let move = line.first?.white else {
            return line.first!.black!
        }
        return move
    }
    
    public var variationStartNumber: Int {
        line.first?.moveNumber ?? 0
    }
    
    public var last:MovePairModel? {
        line.last
    }
    
    public var count:Int {
        line.count
    }
    
    public var all:[MovePairModel] {
        line
    }
    
    public func range(to:MoveModel) -> LineModel {
        guard let index = index(of: to) else { return LineModel() }
        return LineModel(Array(line[line.startIndex...index]))
    }
    
    public func add(_ pair:MovePairModel) {
        line.append(pair)
    }
    
    public func getMove(_ index:Int, color:PieceColor) -> MoveModel? {
        guard index < line.count else { return nil }
        switch color {
        case .white:
            return line[index].white
        case .black:
            return line[index].black
        }
    }
    
    public func getMove(after:MoveModel?) -> MoveModel? {
        guard let fromContainer = after else { return nil }
        guard let rowIndex = index(of:fromContainer) else { return nil }
        guard fromContainer != getMove(rowIndex, color: .white) else {
            return getMove(rowIndex, color: .black)
        }
        return getMove(rowIndex + 1, color: .white)
    }
    
    public func getPair(of:MoveModel) -> MovePairModel? {
        guard let index = index(of: of) else { return nil }
        guard line.count > index else { return nil }
        return line[index]
    }
    
    public func index(of:MoveModel) -> Int? {
        line.firstIndex(where: { $0.white?.id == of.id || $0.black?.id == of.id })
    }
}
