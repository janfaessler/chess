import Foundation
import os

public class MoveListModel : ObservableObject {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MoveListModel")
    
    typealias PositionChangeNotification = (Position) -> ()
    private var positionChangeNotification:[PositionChangeNotification] = []
    
    private let structure = MoveStructure()
    private let history = MoveHistory()
    
    @Published public var currentMove:MoveModel?
    
    public init() {}
    
    public var moveCount:Int {
        structure.count
    }
    
    public var list:[MovePairModel] {
        structure.list
    }
    
    public func start() {
        history.clear()
        currentMove = nil
        updatePosition()
    }
    
    public func back() {
        currentMove = history.pop()
        updatePosition()
    }
    
    public func forward() {
        guard let nextMove = structure.get(after: currentMove) else { return }
        self.currentMove = nextMove
        history.add(nextMove)
        updatePosition()
    }
    
    public func end() {
        currentMove = structure.last
        history.createHistory(ofMove: currentMove, inStructure: structure)
        updatePosition()
    }
    
    public func goToMove(_ move:MoveModel) {
        currentMove = move
        history.createHistory(ofMove: currentMove, inStructure: structure)
        updatePosition()
    }
    
    public func movePlayed(_ move:String) {
        let color = currentMove?.color == .white ? PieceColor.black : PieceColor.white
        let nextMove = structure.get(after: currentMove)
        if move == nextMove?.move {
            replayMove(nextMove!)
            return
        }
        let container = MoveModel(move: move, color: color)
        structure.add(container, currentMove: currentMove)
        history.add(container)
        currentMove = container
    }
    
    public func getPosition() -> Position? {
        guard currentMove != nil else { return PositionFactory.startingPosition() }
        let notations = getMoveNotations()
        return PositionFactory.loadPosition(notations)
    }
    
    public func isCurrentMove(_ container:MoveModel?) -> Bool {
        currentMove == container
    }
    
    public func atStartPosition() -> Bool {
        currentMove == nil
    }
    
    public func reset() {
        currentMove = nil
        structure.clear()
        history.clear()
    }
    
    public func updateMoveList(_ input:MoveStructure) {
        reset()
        structure.set(input)
    }
    
    public func getMoveNotations() -> [String] {
        history.list.map({ $0.move })
    }
    
    func addPositionChangeListener(_ listener:@escaping PositionChangeNotification) {
        positionChangeNotification += [listener]
    }
    
    private func replayMove(_ nextMove: MoveModel) {
        currentMove = nextMove
        history.add(nextMove)
    }
    
    private func updatePosition()  {
        guard let position = getPosition() else { return }
        for event in positionChangeNotification {
            event(position)
        }
    }
}
