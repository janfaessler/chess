import Foundation

public class ResultModel {
    
    let result:GameState
    init (_ gameState: GameState) {
        result = gameState
    }
    
    func shouldDisplay() -> Bool {
        switch result {
        case .NotStarted: return false
        case .Running: return false
        case .WhiteWins: return true
        case .BlackWins: return true
        case .DrawByStalemate: return true
        case .DrawByInsufficientMaterial :return true
        case .DrawBy50MoveRule: return true
        case .DrawByRepetition: return true
        }
    }
    
    func shouldDisplayExplenation() -> Bool {
        switch result {
        case .NotStarted: return false
        case .Running: return false
        case .WhiteWins: return false
        case .BlackWins: return false
        case .DrawByStalemate: return true
        case .DrawByInsufficientMaterial :return true
        case .DrawBy50MoveRule: return true
        case .DrawByRepetition: return true
        }
    }
    
    func getResultText() -> String {
        switch result {
        case .BlackWins: return "Black wins"
        case .WhiteWins: return "White wins"
        case .DrawByStalemate:  return "Draw"
        case .DrawByRepetition: return "Draw"
        case .DrawBy50MoveRule: return "Draw"
        case .DrawByInsufficientMaterial: return "Draw"
        case .NotStarted: return ""
        case .Running: return ""
        }
    }
    
    func getExplenation() -> String {
        switch result {
        case .BlackWins: return ""
        case .WhiteWins: return ""
        case .DrawByStalemate:  return "Stalemalte"
        case .DrawByRepetition: return "Threefold Repetition"
        case .DrawBy50MoveRule: return "50 move rule"
        case .DrawByInsufficientMaterial: return "Insufficien tMaterial"
        case .NotStarted: return ""
        case .Running: return ""
        }
    }
}
