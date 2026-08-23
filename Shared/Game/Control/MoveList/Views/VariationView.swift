import SwiftUI

struct VariationView: View {
    var model: MoveListModel
    var move: MoveModel
    var nestingLevel: Int = 0

    @State private var collapsed: Set<String> = []
    @State private var pendingDeleteVariation: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ForEach(move.getVariations(), id: \.self) { variationName in
                if let variationLine = move.getVariation(variationName) {
                    let isActive = isActiveVariation(variationName)
                    let isCollapsed = collapsed.contains(variationName)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 4) {
                            Button {
                                if isCollapsed {
                                    collapsed.remove(variationName)
                                } else {
                                    collapsed.insert(variationName)
                                }
                            } label: {
                                Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 10)
                            }
                            .buttonStyle(.plain)

                            Text(firstMoveLabel(variationLine))
                                .font(.system(size: 10))
                                .foregroundStyle(isActive ? Color.primary : Color.secondary)

                            Spacer()

                            Button {
                                pendingDeleteVariation = variationName
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .help("Delete variation")
                            .accessibilityIdentifier("variation-delete")
                        }
                        .padding(.horizontal, 2)
                        .padding(.vertical, 2)

                        if !isCollapsed {
                            HStack(alignment: .top, spacing: 0) {
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(isActive ? Color.accentColor.opacity(0.7) : Color.secondary.opacity(0.3))
                                    .frame(width: 2)
                                LineView(model: model, line: variationLine, nestingLevel: nestingLevel)
                                    .padding(.leading, 6)
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 1)
        .accessibilityIdentifier("variation-view")
        .alert("Delete Variation?", isPresented: Binding(
            get: { pendingDeleteVariation != nil },
            set: { if !$0 { pendingDeleteVariation = nil } }
        )) {
            Button("Delete", role: .destructive) {
                if let name = pendingDeleteVariation {
                    model.deleteVariation(name: name, from: move)
                }
                pendingDeleteVariation = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteVariation = nil
            }
        } message: {
            if let name = pendingDeleteVariation,
               let line = move.getVariation(name) {
                Text("Delete the variation starting with \(firstMoveLabel(line))? This cannot be undone.")
            }
        }
    }

    private func firstMoveLabel(_ line: LineModel) -> String {
        guard let first = line.first else { return "" }
        let number = line.variationStartNumber
        switch first.color {
        case .white: return "\(number). \(first.move)"
        case .black: return "\(number)... \(first.move)"
        }
    }

    private func isActiveVariation(_ name: String) -> Bool {
        guard let current = model.currentMove else { return false }
        guard let line = move.getVariation(name) else { return false }
        for pair in line.all {
            if let white = pair.white, white == current || model.isMove(current, childOf: white) {
                return true
            }
            if let black = pair.black, black == current || model.isMove(current, childOf: black) {
                return true
            }
        }
        return false
    }
}
