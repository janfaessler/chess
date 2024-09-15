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
            Button("select PGN") {
                selectedSideBarItem = .openPgn
                focused = false
            }
            List(model.games, id: \.id, selection: $selectedSideBarItem) { selection in
                NavigationLink(selection.getTitle(), value: SideBarItem.game(selection))
            }
            .onChange(of: selectedSideBarItem) {
                focused = true
            }
        } detail:  {
            switch selectedSideBarItem {
                case .openPgn:
                OpenPgnView(model: model)
                case .game(let game):
                GameView(game)
                    .focused($focused)
            }
        }.navigationSplitViewStyle(.balanced)
    }
}
