import SwiftUI
import FilePicker

struct ControlView: View {
    
    @ObservedObject var model:ControlModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FilePicker(types: [.plainText], allowMultiple: false) { urls in
                model.openPgn(urls: urls)
            } label: {
                HStack {
                    Image(systemName: "doc.on.doc")
                    Text("Select PGN")
                }
            }
            EngineView(lines: model.lines)
            MoveListView(model: model.moves)
            Spacer()
            BoardNavigationView(model: model)
        }
    }
}

#Preview {
    ControlView(model: ControlModel())
}
