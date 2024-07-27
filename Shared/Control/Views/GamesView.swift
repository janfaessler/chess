import SwiftUI
import FilePicker

struct GamesView: View {
    @ObservedObject var model:ControlModel

    var body: some View {
        HStack {
            Picker(selection: $model.game) {
                Text("No Option").tag(Optional<PgnGame>(nil))
                ForEach(model.games, id:\.self ) { game in
                    Text(game.getTitle()).tag(game as PgnGame?)
                 }
            } label: {
                PgnLoaderView() { urls in
                    await model.openFiles(urls: urls)
                }
            }.onChange(of: model.game) {
                model.openGame()
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
                buttonText = urls.first?.lastPathComponent ??  "Select PGN"
            }
        } label: {
            HStack {
                Image(systemName: "doc.on.doc")
                Text(buttonText)
            }
        }
    
    }
}
