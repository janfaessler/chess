import SwiftUI

enum SideBarItem: Hashable {
    case openPgn
    case game(PgnGame)
}

struct NavigationManagerView: View {
    @StateObject var model = NavigationManagerModel()
    
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State var selectedSideBarItem: SideBarItem = .openPgn
    @FocusState private var focused: Bool

    var body: some View {
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            Button {
                selectedSideBarItem = .openPgn
                focused = false
            } label: {
                Label("open PGN", systemImage: "plus.circle")
            }
            .buttonStyle(.plain)
            List(selection: $selectedSideBarItem) {
                
                ForEach(model.games, id: \.id) { set in
                    Section {
                        ForEach(set.games, id: \.id) { selection in
                            NavigationLink(selection.getTitle(), value: SideBarItem.game(selection))
                        }
                    } header: {
                        Label(set.name, systemImage: "folder.fill")
                    }
                    
                }
            }
            .onChange(of: selectedSideBarItem) {
                focused = true
            }
            .listStyle(.sidebar)
        } detail:  {
            switch selectedSideBarItem {
                case .openPgn:
                OpenPgnView(model: model)
                case .game(let game):
                GameView(game)
                    .focused($focused)
                    .navigationTitle(game.getTitle())
            }
        }.navigationSplitViewStyle(.balanced)
    }
}
