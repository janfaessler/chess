import Foundation
import os

@Observable
class MoveListModel {
    
    private let logger = Log.logger("MoveListModel")
        
    typealias PositionChangeNotification = (Position) -> ()
    private var positionChangeNotification: [PositionChangeNotification]
    
    private var structure: MoveStructure
    private var history: MoveHistory
    
    var currentMove: MoveModel?

    init() {
        structure = MoveStructure()
        history = MoveHistory()
        positionChangeNotification = []
    }
    
    var moveCount: Int {
        structure.count
    }
    
    var lineModel: LineModel {
        structure.lineModel
    }

    var list: [MovePairModel] {
        structure.list
    }
    
    func start() {
        logger.info("start")
        history.clear()
        currentMove = nil
        updatePosition()
    }
    
    func back() {
        logger.info("back")
        currentMove = history.pop()
        updatePosition()
    }
    
    func forward() {
        logger.info("forward")
        guard let nextMove = structure.get(after: currentMove) else { return }
        self.currentMove = nextMove
        history.add(nextMove)
        updatePosition()
    }
    
    func end() {
        logger.info("end")
        currentMove = structure.last
        history = HistoryFactory.create(ofMove: currentMove, inStructure: structure)
        updatePosition()
    }
    
    func goToMove(_ move:MoveModel) {
        currentMove = move
        history = HistoryFactory.create(ofMove: currentMove, inStructure: structure)
        updatePosition()
    }
    
    func movePlayed(_ move: String, color: PieceColor) {
        if let nextMove = structure.get(after: currentMove), move == nextMove.move {
            currentMove = nextMove
            history.add(nextMove)
            return
        }
        let container = MoveModel(move: move, color: color)
        structure.add(container, currentMove: currentMove)
        history.add(container)
        currentMove = container
    }

    func movePlayed(_ move: String) {
        let color: PieceColor = currentMove?.color == .white ? .black : .white
        movePlayed(move, color: color)
    }
    
    func getPosition() -> Position? {
        guard currentMove != nil else { return PositionFactory.startingPosition() }
        let notations = getMoveNotations()
        return PositionFactory.loadPosition(notations)
    }
    
    func isCurrentMove(_ container:MoveModel?) -> Bool {
        currentMove == container
    }

    func load(_ structure:MoveStructure) {
        currentMove = nil
        history.clear()
        self.structure = structure
    }
    
    func getMoveNotations() -> [String] {
        history.list.map({ $0.move })
    }
    
    func isMove(_ move: MoveModel?, childOf parent: MoveModel) -> Bool {
        structure.move(move, isChildOf: parent)
    }

    func addPositionChangeListener(_ listener: @escaping PositionChangeNotification) {
        self.positionChangeNotification.append(listener)
    }
    
    private func updatePosition() {
        guard let position = self.getPosition() else {
            self.logger.warning("updatePosition: no position available")
            return
        }
        for event in self.positionChangeNotification {
            event(position)
        }
    }
}
