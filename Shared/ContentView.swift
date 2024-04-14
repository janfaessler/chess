import SwiftUI

struct ContentView: View {
    @ObservedObject var model = ControlModel()
    var body: some View {
        GeometryReader{ geo in
            HStack(alignment: .top, spacing:0) {
                BoardView(model.getBoardSize(geo), board:model.board)
                ControlView(model: model)
            }
            
        }
    }
}

#Preview {
    ContentView()
}
