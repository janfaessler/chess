import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model = ControlModel()
    
    var body: some View {
        GeometryReader{ geo in
            HStack(alignment: .top, spacing:0) {
                BoardView(model:model.board)
                    .frame(width: model.getBoardSize(geo), 
                           height: model.getBoardSize(geo))
                ControlView(model: model)
            }
        }
    }
}

#Preview {
    ContentView()
}
