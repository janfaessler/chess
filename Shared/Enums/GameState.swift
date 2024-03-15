import Foundation

public enum GameState {
    case NotStarted, Running, WhiteWins, BlackWins, DrawByStalemate, DrawByInsufficientMaterial, DrawBy50MoveRule
}
