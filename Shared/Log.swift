import Foundation
import os

/// Central factory for `Logger` instances.
///
/// Keeps the subsystem lookup in a single place and avoids force-unwrapping
/// `Bundle.main.bundleIdentifier` at every call site.
enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "SwiftChess"

    static func logger(_ category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}
