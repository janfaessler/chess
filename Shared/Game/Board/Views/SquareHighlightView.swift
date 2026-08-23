import SwiftUI
import SwiftChessCore

extension AnnotationColor {
    var swiftUIColor: Color {
        switch self {
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        case .blue: return .blue
        }
    }
}

struct SquareHighlightView: View {
    let highlight: SquareHighlight
    let fieldSize: CGFloat
    let orientation: BoardOrientation

    var body: some View {
        ZStack {
            highlight.color.swiftUIColor.opacity(0.25)
            Rectangle()
                .strokeBorder(highlight.color.swiftUIColor, lineWidth: 3)
        }
        .frame(width: fieldSize, height: fieldSize)
        .offset(
            x: fieldSize * CGFloat(orientation.visualFile(squareFile) - 1),
            y: fieldSize * CGFloat(orientation.visualRow(squareRow) - 1)
        )
        .allowsHitTesting(false)
        .accessibilityElement()
        .accessibilityIdentifier("highlight-\(highlight.square)")
    }

    private var squareFile: Int { highlight.square.chessFileIndex }
    private var squareRow: Int { highlight.square.chessRowIndex }
}
