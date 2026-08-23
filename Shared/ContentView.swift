import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var model: NavigationManagerModel?

    var body: some View {
        Group {
            if let model {
                NavigationManagerView(model: model)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if model == nil {
                let repository = SwiftDataGameCollectionRepository(modelContext: modelContext)
                let fileRepo = PgnFilesRepository()
                model = NavigationManagerModel(gameDataRepo: repository, fileRepo: fileRepo)
            }
        }
    }
}

#Preview {
    ContentView()
}
