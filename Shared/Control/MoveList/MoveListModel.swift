import Foundation
import os

public class MoveListModel : ObservableObject {
        
    public typealias PositionChangeNotification = (Position) -> ()
    private var positionChangeNotification:[PositionChangeNotification]
    
    private var structure:MoveStructure
    private var history:MoveHistory
    
    @Published public var currentMove:MoveModel?
    
    public init() {
        structure = MoveStructure()
        history = MoveHistory()
        positionChangeNotification = []
    }
    
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
        history = HistoryFactory.create(ofMove: currentMove, inStructure: structure)
        updatePosition()
    }
    
    public func goToMove(_ move:MoveModel) {
        currentMove = move
        history = HistoryFactory.create(ofMove: currentMove, inStructure: structure)
        updatePosition()
    }
    
    public func movePlayed(_ move:String) {
        let nextMove = structure.get(after: currentMove)
        if move == nextMove?.move {
            currentMove = nextMove
            history.add(nextMove!)
            return
        }
        let color = currentMove?.color == .white ? PieceColor.black : PieceColor.white
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

    public func load(_ structure:MoveStructure) {
        currentMove = nil
        history.clear()
        self.structure = structure
    }
    
    public func getMoveNotations() -> [String] {
        history.list.map({ $0.move })
    }
    
    public func shouldShowVariationList(_ currentPair:MovePairModel) -> Bool {
        guard currentMove != currentPair.white || currentMove != currentPair.black else { return true }
        guard structure.move(currentMove, isChildOf:currentPair) else { return false }
        
        return true
    }
    
    public func addPositionChangeListener(_ listener:@escaping PositionChangeNotification) {
        positionChangeNotification += [listener]
    }
    
    private func updatePosition()  {
        guard let position = getPosition() else { return }
        for event in positionChangeNotification {
            event(position)
        }
    }
}
