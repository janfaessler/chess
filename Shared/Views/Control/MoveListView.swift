import SwiftUI

struct MoveListView: View {
    let size:CGSize
    
    @ObservedObject var model:ControlModel
    
    init (_ size:CGSize, model:ControlModel) {
        self.size = size
        self.model = model
    }
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(stride(from: 0, to: model.moves.count, by: 2)), id: \.self) { index in
                MoveRowView(index, width: size.width, model: model)
            }
            Spacer()
        }
        .padding(10)
    }
}


#Preview {
    MoveListView(CGSize(width: 200, height: 500), model: ControlModel())
}
