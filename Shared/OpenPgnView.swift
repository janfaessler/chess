import SwiftUI
import FilePicker

struct OpenPgnView: View {
    
    var model:NavigationManagerModel
    @State var buttonText = "Select PGN"

    var body: some View {
        
        FilePicker(types: [.plainText], allowMultiple: false) { urls in
            buttonText = "loading..."
            Task {
                await model.openFiles(urls: urls)
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

#Preview {
    OpenPgnView(model: NavigationManagerModel())
}
