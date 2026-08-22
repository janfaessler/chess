import SwiftUI

struct EditGameView: View {
    @State private var model: EditGameModel
    var onSave: (GameData) -> Void

    init(navigationModel: NavigationManagerModel, game: GameData, onSave: @escaping (GameData) -> Void) {
        _model = State(wrappedValue: EditGameModel(game: game, navigationModel: navigationModel))
        self.onSave = onSave
    }

    var body: some View {
        @Bindable var model = model
        Form {
            Section("Players") {
                TextField("White", text: $model.white)
                TextField("Black", text: $model.black)
            }
            Section("Event") {
                TextField("Event", text: $model.event)
                TextField("Site", text: $model.site)
                DatePicker("Date", selection: $model.date, displayedComponents: .date)
                TextField("Round", text: $model.round)
            }
            Section {
                ForEach($model.extraHeaders) { $entry in
                    HStack {
                        TextField("", text: $entry.key)
                            .frame(minWidth: 80, maxWidth: 140)
                        Divider()
                        TextField("", text: $entry.value)
                        Button {
                            model.removeTag(entry)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Button {
                    model.addTag()
                } label: {
                    Label("Add Tag", systemImage: "plus")
                }
            } header: {
                Text("Other Tags")
            }
        }
        .formStyle(.grouped)
        .navigationTitle("Edit Game")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    if let saved = model.save() {
                        onSave(saved)
                    }
                }
            }
        }
    }
}
