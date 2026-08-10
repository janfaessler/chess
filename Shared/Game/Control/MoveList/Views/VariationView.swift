import SwiftUI

struct VariationView: View {
    var model: MoveListModel
    var move: MoveModel
    @State private var variation: String?
    @State private var isExpanded: Bool = false
    var moveNumber: Int
    var nestingLevel: Int = 0

    private var backgroundColor: Color {
        switch nestingLevel {
        case 1: return .blue.opacity(0.06)
        case 2: return .green.opacity(0.06)
        case 3: return .orange.opacity(0.06)
        default: return .purple.opacity(0.06)
        }
    }

    private var accentColor: Color {
        switch nestingLevel {
        case 1: return .blue
        case 2: return .green
        case 3: return .orange
        default: return .purple
        }
    }

    // The variation to display: auto-detected from current move takes priority
    // over any manually selected one.
    private var displayedVariation: String? {
        model.activeVariation(of: move) ?? (isExpanded ? variation : nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Menu {
                ForEach(move.getVariations(), id: \.self) { variationName in
                    Button(action: {
                        if self.variation == variationName {
                            self.variation = nil
                            self.isExpanded = false
                        } else {
                            self.variation = variationName
                            self.isExpanded = true
                        }
                    }) {
                        HStack {
                            Text(getName(variationName))
                            if displayedVariation == variationName {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 9))
                        .foregroundStyle(accentColor)

                    Text("Var (\(move.getVariations().count))")
                        .font(.system(size: 10))

                    if let dv = displayedVariation {
                        Text("• \(getName(dv))")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Image(systemName: displayedVariation != nil ? "chevron.down" : "chevron.right")
                        .font(.system(size: 8))
                        .foregroundStyle(accentColor.opacity(0.7))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(accentColor.opacity(0.25), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            if let selectedVariation = displayedVariation,
               let variationLine = move.getVariation(selectedVariation) {
                LineView(model: model, line: variationLine, nestingLevel: nestingLevel)
                    .padding(.leading, 6)
                    .padding(.top, 2)
                    .padding(.trailing, 2)
                    .padding(.bottom, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(backgroundColor.opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(accentColor.opacity(0.15), lineWidth: 0.5)
                    )
            }
        }
        .padding(.vertical, 1)
    }

    func getName(_ variation: String) -> String {
        switch move.color {
        case .white:
            return "\(moveNumber). \(variation)"
        case .black:
            return "\(moveNumber)... \(variation)"
        }
    }
}
