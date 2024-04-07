import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var model = ControlModel()
    let minControlWidth:CGFloat = 200
    var body: some View {
        GeometryReader{ geo in
            if horizontalSizeClass == .compact {
                VStack(alignment: .leading, spacing: 0) {
                    BoardView(getBoardSize(geo), board:model.board)
                    ControlView(getControlSize(geo), model: model)
                }
            } else {
                HStack(alignment: .top, spacing:0) {
                    BoardView(getBoardSize(geo), board:model.board)
                    ControlView(getControlSize(geo), model: model)
                }
            }
        }
    }
    
    func getBoardSize(_ geo:GeometryProxy) -> CGFloat {
        if horizontalSizeClass == .compact {
            return geo.size.width
        }
        return min(geo.size.width - minControlWidth, geo.size.height)
    }
    func getControlSize(_ geo:GeometryProxy) -> CGSize {
        if horizontalSizeClass == .compact {
            return CGSize(width: geo.size.width, height: geo.size.height)
        }
        let boardSize = getBoardSize(geo)
        let boardWidth = boardSize
        let controlWidth = geo.size.width - boardWidth
        return CGSize(width: controlWidth, height: geo.size.height)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
