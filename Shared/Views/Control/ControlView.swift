import SwiftUI

struct ControlView: View {
    
    @ObservedObject var model:ControlModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            EngineView(lines: model.lines)
            MoveListView(model: model)
            Spacer()
            BoardNavigationView(model: model)
        }
    }
}

#Preview {
    ControlView(model: ControlModel())
}
