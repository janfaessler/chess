import SwiftUI

struct ControlView: View {
    let size:CGSize
    
    @ObservedObject var model:ControlModel
    
    init (_ size:CGSize, model:ControlModel) {
        self.size = size
        self.model = model
    }
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(stride(from: 0, to: model.positions.count, by: 2)), id: \.self) { index in
                RowView(index / 2 + 1, positions: model.positions[index...(model.positions.count > index + 1 ? index + 1 : index)], width: size.width)
            }
            Spacer()
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview {
    ControlView(CGSize(width: 200, height: 500), model: ControlModel())
}
