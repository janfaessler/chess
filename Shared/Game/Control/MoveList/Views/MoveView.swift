import SwiftUI
import SwiftChessCore

extension MoveAnnotation {
    var displayColor: Color {
        switch self {
        case .brilliant: return .cyan
        case .good: return .green
        case .interesting: return .teal
        case .dubious: return .orange
        case .mistake: return .orange
        case .blunder: return .red
        }
    }
}

struct MoveView: View {

    let model: MoveListModel
    let move: MoveModel
    let action: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 1) {
                Text(move.move)
                    .font(.system(.callout, design: .default))
                    .fontWeight(model.isCurrentMove(move) ? .semibold : .regular)

                if let annotation = move.annotation {
                    Text(annotation.symbol)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(annotation.displayColor)
                }

                if move.hasVariations() {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 7))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(model.isCurrentMove(move) ? .blue.opacity(0.15) : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(model.isCurrentMove(move) ? .blue : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("movelist-\(move.move)")
        .accessibilityAddTraits(model.isCurrentMove(move) ? .isSelected : [])
        .contextMenu {
            Menu("Assessment") {
                Button("None") { model.setAnnotation(nil, for: move) }
                Divider()
                ForEach(MoveAnnotation.allCases, id: \.self) { annotation in
                    Button {
                        model.setAnnotation(annotation, for: move)
                    } label: {
                        Label(
                            "\(annotation.symbol) \(annotation.displayName)",
                            systemImage: move.annotation == annotation ? "checkmark" : "circle"
                        )
                    }
                }
            }
            Divider()
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete from here", systemImage: "trash")
            }
        }
        .alert("Delete from here?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                model.deleteFrom(move)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Delete \"\(move.move)\" and all following moves? This cannot be undone.")
        }
    }
}
