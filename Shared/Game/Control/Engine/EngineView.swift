import SwiftUI

struct EngineView: View {
    var model: ControlModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(model.lines.prefix(3)), id: \.id) { line in
                HStack(spacing: 8) {
                    Text(line.score)
                        .font(.system(.caption, design: .monospaced, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(evaluationColor(for: line.score), in: .capsule)
                        .foregroundStyle(.white)
                    
                    Text(line.line)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("engine-line-\(line.id)")
            }
        }
    }
    
    private func evaluationColor(for eval: String) -> Color {
        if eval.hasPrefix("+") {
            return .green
        } else if eval.hasPrefix("-") {
            return .red
        } else {
            return .secondary
        }
    }
}
