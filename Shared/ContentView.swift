import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model = ControlModel()
    
    var body: some View {
        GeometryReader{ geo in
            HStack(alignment: .top, spacing:0) {
                let boardSize = model.getBoardSize(geo)
                BoardView(model:model.board)
                    .frame(width: boardSize, height: boardSize)
                ControlView(model: model)
            }
        }
    }
}

#Preview {
    ContentView()
}
