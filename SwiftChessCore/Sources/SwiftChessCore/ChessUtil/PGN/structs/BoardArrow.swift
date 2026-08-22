import Foundation

public struct BoardArrow: Codable, Hashable, Sendable {
    public let color: AnnotationColor
    public let from: String
    public let to: String

    public init(color: AnnotationColor, from: String, to: String) {
        self.color = color
        self.from = from
        self.to = to
    }
}
