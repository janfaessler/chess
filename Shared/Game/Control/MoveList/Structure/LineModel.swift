import Foundation
import Observation
import SwiftChessCore

@Observable
class LineModel {
    var line:[MovePairModel]

    init(_ line: [MovePairModel] = []) {
        self.line = line
    }

    var first:MoveModel? {
        guard let move = line.first?.white else {
            return line.first?.black
        }
        return move
    }

    var variationStartNumber: Int {
        line.first?.moveNumber ?? 0
    }

    var last:MovePairModel? {
        line.last
    }

    var count:Int {
        line.count
    }

    var all:[MovePairModel] {
        line
    }

    func range(to:MoveModel) -> LineModel {
        guard let index = index(of: to) else { return LineModel() }
        return LineModel(Array(line[line.startIndex...index]))
    }

    func add(_ pair:MovePairModel) {
        line.append(pair)
    }

    func getMove(_ index:Int, color:PieceColor) -> MoveModel? {
        guard index < line.count else { return nil }
        switch color {
        case .white:
            return line[index].white
        case .black:
            return line[index].black
        }
    }

    func getMove(after:MoveModel?) -> MoveModel? {
        guard let fromContainer = after else { return nil }
        guard let rowIndex = index(of:fromContainer) else { return nil }
        guard fromContainer != getMove(rowIndex, color: .white) else {
            return getMove(rowIndex, color: .black)
        }
        return getMove(rowIndex + 1, color: .white)
    }

    func getPair(of:MoveModel) -> MovePairModel? {
        guard let index = index(of: of) else { return nil }
        guard line.count > index else { return nil }
        return line[index]
    }

    func index(of:MoveModel) -> Int? {
        line.firstIndex(where: { $0.white?.id == of.id || $0.black?.id == of.id })
    }
}
