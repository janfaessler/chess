import SwiftUI

struct NavigationManagerView: View {
    var model: NavigationManagerModel
    @Environment(EngineSettings.self) private var engineSettings
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State var selectedSideBarItem: SideBarItem = .openPgn
    @FocusState private var focusOnGame: Bool

    var body: some View {
        @Bindable var bModel = model
        
        VStack(spacing: 0) {
            if let error = model.appError {
                HStack {
                    Image(systemName: "exclamationmark.octagon.fill")
                    Text(error.message)
                    Spacer()
                    if error.isRetryable {
                        Button("Retry") {
                            model.retry()
                        }
                        .buttonStyle(.borderless)
                    }
                    Button("OK") {
                        model.dismissError()
                    }
                    .buttonStyle(.borderless)
                }
                .padding()
                .background(Color(.systemRed).opacity(0.15))
                .foregroundColor(.red)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            NavigationSplitView(columnVisibility: $sideBarVisibility) {
                List(selection: $selectedSideBarItem) {
                    ForEach($bModel.collections) { $collection in
                        Section(isExpanded: $collection.expanded) {
                            ForEach(collection.games, id: \.id) { gameData in
                                NavigationLink(gameData.getTitle(), value: SideBarItem.game(gameData))
                                    .accessibilityIdentifier("sidebar-game-\(gameData.getTitle())")
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            if case .game(let selected) = selectedSideBarItem, selected.id == gameData.id {
                                                selectedSideBarItem = .openPgn
                                            }
                                            model.removeGame(gameData)
                                        } label: {
                                            Label("Delete Game", systemImage: "trash")
                                        }
                                        .accessibilityIdentifier("sidebar-deletegame-\(gameData.getTitle())")
                                    }
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
                                    selectedSideBarItem = .addGame(collection)
                                } label: {
                                    Label("add", systemImage: "plus.circle")
                                        .labelStyle(.iconOnly)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("sidebar-addgame-\(collection.name)")
                            }
                        }
                        .onChange(of: collection.expanded) { model.save() }
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
                .navigationTitle("")
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
            } detail: {
                switch selectedSideBarItem {
                case .openPgn:
                    OpenPgnView(model: model)
                        .navigationTitle("Open PGN")
                case .createPgn:
                    CreatePgnView(model: model)
                        .navigationTitle("New Collection")
                case .editCollection(let collection):
                    EditCollectionView(model: model, collection: collection, selectedSideBarItem: $selectedSideBarItem)
                case .addGame(let collection):
                    EditGameView(navigationModel: model, game: GameData(headers: [:], moves: [], result: "*", comment: nil), targetCollection: collection) { added in
                        selectedSideBarItem = .game(added)
                    }
                    .navigationTitle("")
                case .editGame(let gameData):
                    EditGameView(navigationModel: model, game: gameData) { updated in
                        selectedSideBarItem = .game(updated)
                    }
                    .navigationTitle("")
                case .game(let gameData):
                    GameView(gameData, settings: engineSettings)
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
                                .accessibilityIdentifier("edit-game")
                            }
                        }
                }
            }
            .navigationSplitViewStyle(.balanced)
        }
    }
}
