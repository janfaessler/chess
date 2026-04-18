import SwiftUI

struct CommentView: View {
    var model: ControlModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Notes", systemImage: "note.text")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if !model.comment.isEmpty {
                Text(model.comment)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("No notes for this position")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
        }
    }
}
