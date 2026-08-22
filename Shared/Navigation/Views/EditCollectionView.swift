import SwiftUI

struct EditCollectionView: View {
    var model: NavigationManagerModel
    var collection: GameCollection
    @Binding var selectedSideBarItem: SideBarItem
    @State private var name: String = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                LabeledContent("Games", value: "\(collection.games.count)")
            }
            Section {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Collection", systemImage: "trash")
                }
                .accessibilityIdentifier("delete-collection")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Edit \(name)")
        .onAppear { name = collection.name }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    let updated = GameCollection(id: collection.id, name: name, expanded: collection.expanded, games: collection.games)
                    model.updateCollection(updated)
                    selectedSideBarItem = .editCollection(updated)
                }
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .confirmationDialog(
            "Delete \"\(collection.name)\"?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Collection", role: .destructive) {
                model.removeCollection(collection)
                selectedSideBarItem = .openPgn
            }
        } message: {
            Text("This will permanently delete the collection and all \(collection.games.count) game(s) in it.")
        }
    }
}
