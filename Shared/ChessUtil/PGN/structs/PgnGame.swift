import Foundation

public struct PgnGame : Identifiable {
    public let id = UUID()
    public let headers:[String:String]
    public let moves:[PgnMove]
    public let result:String
    public let comment:String?
    
    public func getTitle() -> String {
        guard let white = headers["White"],
              let black = headers["Black"]
        else { return headers["Event"] ?? "???" }
        return "\(white) - \(black)"
    }
}
