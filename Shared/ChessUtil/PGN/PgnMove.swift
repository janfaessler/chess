import Foundation

public struct PgnMove {
    public let id = UUID()
    public let move:String
    public let variations:[[PgnMove]]
    public let comment:String?
}
