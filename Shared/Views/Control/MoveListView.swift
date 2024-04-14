import SwiftUI

struct MoveListView: View {
    
    @ObservedObject var model:ControlModel
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(stride(from: 0, to: model.moves.count, by: 2)), id: \.self) { index in
                MoveRowView(index, model: model)
            }
            Spacer()
        }
        .padding(10)
    }
}


#Preview {
    MoveListView(model: ControlModel())
}
