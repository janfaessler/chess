import SwiftUI

struct MoveView: View {
    
    let model: MoveListModel
    let move: MoveModel
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 1) {
                Text(move.move)
                    .font(.system(.callout, design: .default))
                    .fontWeight(model.isCurrentMove(move) ? .semibold : .regular)
                
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
    }
}
