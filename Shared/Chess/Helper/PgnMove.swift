import Foundation

public struct PgnMove {
    let id = UUID()
    let move:String
    let variations:[[PgnMove]]
    let comment:String?
}
