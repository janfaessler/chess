import SwiftUI
import SwiftData
import FilePicker

struct OpenPgnView: View {
    
    var model: NavigationManagerModel
    @State private var buttonText = "Select PGN File"
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue.gradient)
                
                Text("Import PGN Files")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Select one or more PGN files to import your chess games")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            FilePicker(types: [.plainText], allowMultiple: true) { urls in
                isLoading = true
                buttonText = "Loading..."
                Task {
                    await model.openFiles(urls: urls)
                    isLoading = false
                    if let firstURL = urls.first {
                        buttonText = "Imported: \(firstURL.lastPathComponent)"
                    } else {
                        buttonText = "Select PGN File"
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "square.and.arrow.down")
                            .font(.title3)
                    }
                    
                    Text(buttonText)
                        .font(.headline)
                }
                .frame(maxWidth: 320)
                .padding(.vertical, 14)
                .padding(.horizontal, 24)
                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("Supported Formats")
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    InfoRowView(icon: "checkmark.circle.fill", 
                               text: "Standard PGN format (.pgn)")
                    InfoRowView(icon: "checkmark.circle.fill", 
                               text: "Multiple games in one file")
                    InfoRowView(icon: "checkmark.circle.fill", 
                               text: "Games with variations and annotations")
                }
                .padding(.leading, 8)
            }
            .padding()
            .frame(maxWidth: 400)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}



#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CollectionEntity.self, GameEntity.self, configurations: config)
    OpenPgnView(model: NavigationManagerModel(repository: SwiftDataGameCollectionRepository(modelContext: container.mainContext)))
}
