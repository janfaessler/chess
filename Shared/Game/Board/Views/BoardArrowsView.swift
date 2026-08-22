import SwiftUI
import SwiftChessCore

struct BoardArrowsView: View {
    let arrows: [BoardArrow]
    let fieldSize: CGFloat
    let orientation: BoardOrientation

    var body: some View {
        Canvas { context, _ in
            for arrow in arrows {
                let path = arrowPath(from: arrow.from, to: arrow.to)
                context.fill(path, with: .color(arrow.color.swiftUIColor.opacity(0.75)))
            }
        }
        .allowsHitTesting(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if !arrows.isEmpty {
                Color.clear
                    .accessibilityElement()
                    .accessibilityIdentifier("arrows-overlay")
            }
        }
    }

    private func squareCenter(_ square: String) -> CGPoint {
        CGPoint(
            x: fieldSize * CGFloat(orientation.visualFile(squareFile(square)) - 1) + fieldSize / 2,
            y: fieldSize * CGFloat(orientation.visualRow(squareRow(square)) - 1) + fieldSize / 2
        )
    }

    private func arrowPath(from fromSquare: String, to toSquare: String) -> Path {
        let start = squareCenter(fromSquare)
        let end = squareCenter(toSquare)

        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = sqrt(dx * dx + dy * dy)
        guard length > 0 else { return Path() }

        let ux = dx / length
        let uy = dy / length
        let px = -uy
        let py = ux

        let shaftWidth = fieldSize * 0.18
        let headWidth = fieldSize * 0.38
        let headLength = fieldSize * 0.38
        let inset = fieldSize * 0.1

        let shaftStart = CGPoint(x: start.x + ux * inset, y: start.y + uy * inset)
        let shaftEnd = CGPoint(x: end.x - ux * headLength, y: end.y - uy * headLength)

        var path = Path()
        path.move(to: CGPoint(x: shaftStart.x + px * shaftWidth / 2, y: shaftStart.y + py * shaftWidth / 2))
        path.addLine(to: CGPoint(x: shaftEnd.x + px * shaftWidth / 2, y: shaftEnd.y + py * shaftWidth / 2))
        path.addLine(to: CGPoint(x: shaftEnd.x + px * headWidth / 2, y: shaftEnd.y + py * headWidth / 2))
        path.addLine(to: CGPoint(x: end.x, y: end.y))
        path.addLine(to: CGPoint(x: shaftEnd.x - px * headWidth / 2, y: shaftEnd.y - py * headWidth / 2))
        path.addLine(to: CGPoint(x: shaftEnd.x - px * shaftWidth / 2, y: shaftEnd.y - py * shaftWidth / 2))
        path.addLine(to: CGPoint(x: shaftStart.x - px * shaftWidth / 2, y: shaftStart.y - py * shaftWidth / 2))
        path.closeSubpath()
        return path
    }

    private func squareFile(_ square: String) -> Int {
        guard let c = square.first else { return 1 }
        return Int(c.asciiValue! - Character("a").asciiValue!) + 1
    }

    private func squareRow(_ square: String) -> Int {
        guard square.count >= 2, let r = Int(String(square.dropFirst())) else { return 1 }
        return r
    }
}
