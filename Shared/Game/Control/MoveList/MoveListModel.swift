import Foundation
import os
import SwiftChessCore

@Observable
class MoveListModel {
    
    private let logger = Log.logger("MoveListModel")

    /// Emits the board position whenever navigation changes the current move.
    let positionChanged: AsyncStream<Position>
    private let positionContinuation: AsyncStream<Position>.Continuation

    private var structure: MoveStructure
    private var history: MoveHistory

    var currentMove: MoveModel?

    init() {
        structure = MoveStructure()
        history = MoveHistory()
        (positionChanged, positionContinuation) = AsyncStream.makeStream(of: Position.self)
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
        let basePosition = currentMove?.resultingPosition ?? (try! PositionFactory.startingPosition())
        let container = MoveModel(move: move, color: color, resultingPosition: PositionFactory.apply(move, to: basePosition))
        structure.add(container, currentMove: currentMove)
        history.add(container)
        currentMove = container
    }

    func movePlayed(_ move: String) {
        let color: PieceColor = currentMove?.color == .white ? .black : .white
        movePlayed(move, color: color)
    }
    
    var position: Position? {
        guard let currentMove else { return try! PositionFactory.startingPosition() }
        return currentMove.resultingPosition ?? PositionFactory.loadPosition(getMoveNotations())
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

    func deleteFrom(_ move: MoveModel) {
        structure.deleteFrom(move)
        resetCurrentMoveIfNeeded()
    }

    func deleteVariation(name: String, from: MoveModel) {
        structure.deleteVariation(name: name, from: from)
        resetCurrentMoveIfNeeded()
    }

    func setAnnotation(_ annotation: MoveAnnotation?, for move: MoveModel) {
        move.annotation = annotation
    }

    private func resetCurrentMoveIfNeeded() {
        guard let current = currentMove else { return }
        guard !isCurrentMoveReachable(current) else { return }
        currentMove = nil
        history.clear()
        updatePosition()
    }

    private func isCurrentMoveReachable(_ move: MoveModel) -> Bool {
        if structure.lineModel.index(of: move) != nil { return true }
        if structure.parent(of: move) != nil { return true }
        return false
    }

    private func updatePosition() {
        guard let position = self.position else {
            self.logger.warning("updatePosition: no position available")
            return
        }
        positionContinuation.yield(position)
    }
}
