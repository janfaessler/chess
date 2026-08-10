import Foundation
import os

@Observable
public class MoveListModel {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "MoveListModel")
        
    public typealias PositionChangeNotification = (Position) -> ()
    private var positionChangeNotification: [PositionChangeNotification]
    
    private var structure: MoveStructure
    private var history: MoveHistory
    
    public var currentMove: MoveModel?

    public init() {
        structure = MoveStructure()
        history = MoveHistory()
        positionChangeNotification = []
    }
    
    public var moveCount: Int {
        structure.count
    }
    
    public var lineModel: LineModel {
        structure.lineModel
    }

    public var list: [MovePairModel] {
        structure.list
    }
    
    public func start() {
        logger.info("start")
        history.clear()
        currentMove = nil
        updatePosition()
    }
    
    public func back() {
        logger.info("back")
        currentMove = history.pop()
        updatePosition()
    }
    
    public func forward() {
        logger.info("forward")
        guard let nextMove = structure.get(after: currentMove) else { return }
        self.currentMove = nextMove
        history.add(nextMove)
        updatePosition()
    }
    
    public func end() {
        logger.info("end")
        currentMove = structure.last
        history = HistoryFactory.create(ofMove: currentMove, inStructure: structure)
        updatePosition()
    }
    
    public func goToMove(_ move:MoveModel) {
        currentMove = move
        history = HistoryFactory.create(ofMove: currentMove, inStructure: structure)
        updatePosition()
    }
    
    public func movePlayed(_ move: String, color: PieceColor) {
        let nextMove = structure.get(after: currentMove)
        if move == nextMove?.move {
            currentMove = nextMove
            history.add(nextMove!)
            return
        }
        let container = MoveModel(move: move, color: color)
        structure.add(container, currentMove: currentMove)
        history.add(container)
        currentMove = container
    }

    public func movePlayed(_ move: String) {
        let color: PieceColor = currentMove?.color == .white ? .black : .white
        movePlayed(move, color: color)
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
        if shouldShowVariationList(currentPair, color: .white) {
            return true
        }
        if shouldShowVariationList(currentPair, color: .black) {
            return true
        }
        return false
    }
    
    public func shouldShowVariationList(_ currentPair:MovePairModel, color:PieceColor) -> Bool {
        if currentMove == nil {
            return false
        }
        
        if color == .white {
            
            if currentMove == currentPair.white { return currentMove!.hasVariations() }
            guard currentPair.white != nil else { return false }
            if structure.move(currentMove, isChildOf: currentPair.white!) {
                return true
            }
        } else {
            if currentMove == currentPair.black { return currentMove!.hasVariations() }
            guard currentPair.black != nil else { return false }
            if structure.move(currentMove, isChildOf: currentPair.black!) {
                return true
            }
        }
        
        
        return false
    }
    
    public func activeVariation(of move: MoveModel) -> String? {
        for name in move.getVariations() {
            guard let line = move.getVariation(name) else { continue }
            for pair in line.all {
                if let white = pair.white, white == currentMove || structure.move(currentMove, isChildOf: white) {
                    return name
                }
                if let black = pair.black, black == currentMove || structure.move(currentMove, isChildOf: black) {
                    return name
                }
            }
        }
        return nil
    }

    public func addPositionChangeListener(_ listener: @escaping PositionChangeNotification) {
        self.positionChangeNotification.append(listener)
    }
    
    private func updatePosition() {
        self.logger.info("MoveListModel.updatePosition called")
        guard let position = self.getPosition() else {
            self.logger.warning("MoveListModel.updatePosition - no position available")
            return
        }
        self.logger.info("MoveListModel.updatePosition - calling \(self.positionChangeNotification.count) listeners")
        for event in self.positionChangeNotification {
            event(position)
        }
        self.logger.info("MoveListModel.updatePosition - listeners called")
    }
}
