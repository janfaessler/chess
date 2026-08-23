import SwiftUI

struct EngineLine: Hashable, Identifiable {
    let id: Int
    let score: String
    let line: String

    var badgeColor: Color {
        if score.hasPrefix("+") { return .green }
        if score.hasPrefix("-") { return .red }
        return .secondary
    }
}
