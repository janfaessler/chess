import Foundation

public struct SquareHighlight: Codable, Hashable, Sendable {
    public let color: AnnotationColor
    public let square: String

    public init(color: AnnotationColor, square: String) {
        self.color = color
        self.square = square
    }
}
