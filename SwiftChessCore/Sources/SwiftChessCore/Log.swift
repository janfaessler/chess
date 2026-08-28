import Foundation
import os

enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "SwiftChessCore"

    static func logger(_ category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}
