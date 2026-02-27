import SwiftUI


struct NavigationManagerView: View {
    @StateObject var model = NavigationManagerModel()
    
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State var selectedSideBarItem: SideBarItem = .openPgn
    @FocusState private var focusOnGame: Bool

    var body: some View {
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            List(selection: $selectedSideBarItem) {
                ForEach(model.collections, id: \.id) { collection in
                    Section {
                        ForEach(collection.games, id: \.id) { selection in
                            NavigationLink(selection.getTitle(), value: SideBarItem.game(selection))
                        }
                    } header: {
                        HStack {
                            Button {
                                selectedSideBarItem = .editCollection(collection)
                            } label: {
                                Label(collection.name, systemImage: "folder.fill")
                            }
                            .buttonStyle(.plain)
                            Spacer()
                            Button {
                                selectedSideBarItem = .addGame
                            } label: {
                                Label("add", systemImage: "plus.circle")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .onChange(of: selectedSideBarItem) {
                if case .game(_) = selectedSideBarItem {
                    focusOnGame = true
                } else {
                    focusOnGame = false
                }
            }
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        selectedSideBarItem = .openPgn
                    } label: {
                        Label("open PGN", systemImage: "doc.on.doc")
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        selectedSideBarItem = .createPgn
                    } label: {
                        Label("create PGN", systemImage: "folder.badge.plus")
                    }
                    .buttonStyle(.plain)
                }
            }
        } detail:  {
            switch selectedSideBarItem {
            case .openPgn:
                OpenPgnView(model: model)
                    .navigationTitle("Open PGN")
            case .createPgn:
                CreatePgnView(model: model)
                    .navigationTitle("Add Collection")
            case .editCollection(let collection):
                EditCollectionView(model: model, collection: collection)
                    .navigationTitle("Edit <" + collection.name + ">")
            case .addGame:
                AddGameView(model: model)
                    .navigationTitle("Add Game")
            case .editGame(let game):
                EditGameView(model: model, game: game)
                    .navigationTitle("Edit <" + game.getTitle() + ">")
            case .game(let game):
                GameView(game)
                    .focused($focusOnGame)
                    .navigationTitle(game.getTitle())
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button {
                                selectedSideBarItem = .editGame(game)
                            } label: {
                                Label("edit game", systemImage: "pencil")
                            }
                            .buttonStyle(.plain)
                        }
                    }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
