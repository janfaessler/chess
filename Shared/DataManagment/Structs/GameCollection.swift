import Foundation
import os

struct GameCollection : Hashable {
    let id:UUID =  UUID()
    let name:String
    var expanded:Bool
    var games:[PgnGame] = []
}
