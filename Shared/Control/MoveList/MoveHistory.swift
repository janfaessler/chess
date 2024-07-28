import Foundation

public class MoveHistory {
    private var history: [MoveModel]
    
    public init(history: [MoveModel] = []) {
        self.history = history
    }

    public func clear() {
        history.removeAll()
    }
    
    public func pop() -> MoveModel? {
        guard history.isEmpty == false else { return nil }
        history.removeLast()
        return history.last
    }
    
    public func add(_ move:MoveModel) {
        history.append(move)
    }
    
    public var list:[MoveModel] {
        history
    }
    
    public func rowNumber() -> Int {
        Int(history.count / 2) + 1
    }
}
