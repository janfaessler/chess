import SwiftUI
import FilePicker

struct ControlView: View {
    
    @ObservedObject var model:ControlModel
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                PgnLoaderView() { urls in
                    await model.openFiles(urls: urls)
                }
                GamesView(model: model)
                    .frame(maxHeight: geo.size.height * 0.3)
                EngineView(lines: model.lines)
                MoveListView(model: model.moves)
                Spacer()
                BoardNavigationView(model: model)
            }
        }
    }
}

struct PgnLoaderView: View {
    let action: ([URL]) async -> Void
    @State var buttonText = "Select PGN"

    init(_ action: @escaping  ([URL]) async -> Void) {
        self.action = action
    }
    
    var body: some View {
        FilePicker(types: [.plainText], allowMultiple: false) { urls in
            buttonText = "loading..."
            Task {
                await action(urls)
                buttonText = "Select PGN"
            }
        } label: {
            HStack {
                Image(systemName: "doc.on.doc")
                Text(buttonText)
            }
        }
    
    }
}
