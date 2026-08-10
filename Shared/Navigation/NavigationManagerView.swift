import SwiftUI

struct NavigationManagerView: View {
    var model: NavigationManagerModel
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State var selectedSideBarItem: SideBarItem = .openPgn
    @FocusState private var focusOnGame: Bool

    var body: some View {
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            List(selection: $selectedSideBarItem) {
                ForEach(model.collections, id: \.id) { collection in
                    Section {
                        ForEach(collection.games, id: \.id) { gameData in
                            NavigationLink(gameData.getTitle(), value: SideBarItem.game(gameData))
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
                    .collapsible(true)
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
            .scrollContentBackground(.hidden)
            .background(Color(nsColor: .windowBackgroundColor))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            selectedSideBarItem = .openPgn
                        } label: {
                            Label("Open PGN", systemImage: "doc.on.doc")
                        }

                        Button {
                            selectedSideBarItem = .createPgn
                        } label: {
                            Label("New Collection", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Label("Actions", systemImage: "plus.circle.fill")
                    }
                    .menuStyle(.button)
                }
            }
            .navigationTitle("Collections")
        } detail: {
            switch selectedSideBarItem {
            case .openPgn:
                OpenPgnView(model: model)
                    .navigationTitle("Open PGN")
            case .createPgn:
                CreatePgnView(model: model)
                    .navigationTitle("New Collection")
            case .editCollection(let collection):
                EditCollectionView(model: model, collection: collection)
                    .navigationTitle("Edit \(collection.name)")
            case .addGame:
                AddGameView(model: model)
                    .navigationTitle("Add Game")
            case .editGame(let gameData):
                EditGameView(model: model, game: gameData)
                    .navigationTitle("Edit \(gameData.getTitle())")
            case .game(let gameData):
                GameView(gameData.toPgnGame())
                    .id(gameData.id)
                    .focused($focusOnGame)
                    .navigationTitle(gameData.getTitle())
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button {
                                selectedSideBarItem = .editGame(gameData)
                            } label: {
                                Label("Edit Game", systemImage: "pencil")
                            }
                            .buttonStyle(.plain)
                        }
                    }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
