import Foundation

public struct PgnGame {
    public let id = UUID()
    public let headers:[String]
    public let moves:[PgnMove]
    public let result:String
    public let comment:String?
}
