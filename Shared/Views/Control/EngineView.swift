import SwiftUI

struct EngineView: View {
    
    let size:CGSize
    @ObservedObject var model:ControlModel
    
    init (_ size:CGSize, model:ControlModel) {
        self.size = size
        self.model = model
    }
    var body: some View {
        Text(model.engineEval)
    }
}

#Preview {
    EngineView(CGSize(width: 200, height: 30), model:ControlModel())
}
