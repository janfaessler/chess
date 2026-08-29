import Foundation
import os

enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "SwiftChess"

    static func logger(_ category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}
