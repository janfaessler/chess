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
                                .accessibilityIdentifier("sidebar-game-\(gameData.getTitle())")
                        }
                    } header: {
                        HStack {
                            Button {
                                selectedSideBarItem = .editCollection(collection)
                            } label: {
                                Label(collection.name, systemImage: "folder.fill")
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("sidebar-collection-\(collection.name)")
                            Spacer()
                            Button {
                                selectedSideBarItem = .addGame
                            } label: {
                                Label("add", systemImage: "plus.circle")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("sidebar-addgame-\(collection.name)")
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
                        .accessibilityIdentifier("actions-open-pgn")

                        Button {
                            selectedSideBarItem = .createPgn
                        } label: {
                            Label("New Collection", systemImage: "folder.badge.plus")
                        }
                        .accessibilityIdentifier("actions-new-collection")
                    } label: {
                        Label("Actions", systemImage: "plus.circle.fill")
                    }
                    .menuStyle(.button)
                    .accessibilityIdentifier("actions-menu")
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
                GameView(gameData)
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
                            .accessibilityIdentifier("edit-game")
                        }
                    }
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
