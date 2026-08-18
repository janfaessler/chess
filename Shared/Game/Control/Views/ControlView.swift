import SwiftUI

struct ControlView: View {
    var model: ControlModel
    
    var body: some View {
        VStack(spacing: 16) {

            if !model.lines.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Analysis", systemImage: "cpu")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("analysis-panel")
                    EngineView(model: model)
                }
                .padding()
                .background(.regularMaterial, in: .rect(cornerRadius: 12))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Moves", systemImage: "list.bullet")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                MoveListView(model: model.moveList)
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 12))
            
            Spacer()
            
            if !model.comment.isEmpty {
                CommentView(model: model)
                    .padding()
                    .background(.thinMaterial, in: .rect(cornerRadius: 12))
            }
            
            BoardNavigationView(model: model)
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 12))
        }
        .padding(16)
    }
}
