import Foundation

public enum GameState {
    case notStarted, running, whiteWins, blackWins, drawByStalemate, drawByInsufficientMaterial, drawBy50MoveRule, drawByRepetition
}
