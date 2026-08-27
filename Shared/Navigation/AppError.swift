import Foundation

enum AppError {
    case loadFailed(Error)
    case saveFailed(Error)
    case importFailed(filename: String, Error)

    var message: String {
        switch self {
        case .loadFailed(let e):
            return "Failed to load collections: \(e.localizedDescription)"
        case .saveFailed(let e):
            return "Failed to save: \(e.localizedDescription)"
        case .importFailed(let filename, let e):
            return "Failed to import \(filename): \(e.localizedDescription)"
        }
    }

    var isRetryable: Bool {
        switch self {
        case .loadFailed, .saveFailed: return true
        case .importFailed: return false
        }
    }
}
