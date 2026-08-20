import Foundation

public struct PgnMove : Sendable {
    public let id = UUID()
    public let move:String
    public let variations:[[PgnMove]]
    public let comment:String?
}
