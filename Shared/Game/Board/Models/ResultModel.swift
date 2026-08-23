import Foundation
import SwiftChessCore

public class ResultModel {

    let result: GameState
    init(_ gameState: GameState) {
        result = gameState
    }

    func shouldDisplay() -> Bool {
        switch result {
        case .notStarted, .running: return false
        default: return true
        }
    }

    func shouldDisplayExplanation() -> Bool {
        switch result {
        case .drawByStalemate, .drawByInsufficientMaterial, .drawBy50MoveRule, .drawByRepetition: return true
        default: return false
        }
    }

    func getResultText() -> String {
        switch result {
        case .whiteWins: return "White wins"
        case .blackWins: return "Black wins"
        case .drawByStalemate, .drawByRepetition, .drawBy50MoveRule, .drawByInsufficientMaterial: return "Draw"
        case .notStarted, .running: return ""
        }
    }

    func getExplanation() -> String {
        switch result {
        case .drawByStalemate: return "Stalemate"
        case .drawByRepetition: return "Threefold Repetition"
        case .drawBy50MoveRule: return "50-move rule"
        case .drawByInsufficientMaterial: return "Insufficient material"
        default: return ""
        }
    }
}
