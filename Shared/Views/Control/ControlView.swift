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
            ForEach(Array(stride(from: 0, to: model.moves.count, by: 2)), id: \.self) { index in
                RowView(index / 2 + 1, 
                        positions: model.moves[index...(model.moves.count > index + 1 ? index + 1 : index)],
                        width: size.width,
                        highlight: model.currentMove == index + 1 ? .white : (model.currentMove == index + 2 ? .black : nil))
            }
            Spacer()
            HStack {
                Button("back") { model.back() }
                Button("forward"){ model.forward() }
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview {
    ControlView(CGSize(width: 200, height: 500), model: ControlModel())
}
