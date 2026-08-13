import Foundation

class MoveHistory {
    private var history: [MoveModel]
    
    init(history: [MoveModel] = []) {
        self.history = history
    }

    func clear() {
        history.removeAll()
    }
    
    func pop() -> MoveModel? {
        guard history.isEmpty == false else { return nil }
        history.removeLast()
        return history.last
    }
    
    func add(_ move:MoveModel) {
        history.append(move)
    }
    
    var list:[MoveModel] {
        history
    }
}
