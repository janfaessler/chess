import SwiftUI

enum SideBarItem: Hashable {
    case openPgn
    case createPgn
    case editCollection(GameCollection)
    case addGame
    case editGame(GameData)
    case game(GameData)
}
