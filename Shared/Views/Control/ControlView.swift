import SwiftUI

struct ControlView: View {
    let size:CGSize
    let navigationSize:CGSize
    let moveListSize:CGSize
    let engineSize:CGSize
    
    @ObservedObject var model:ControlModel
    
    init (_ size:CGSize, model:ControlModel) {
        self.size = size
        self.model = model
        self.navigationSize = CGSize(width: size.width, height: 30)
        self.engineSize = CGSize(width: size.width, height: 30)
        self.moveListSize = CGSize(width: size.width, height: size.height - navigationSize.height - engineSize.height)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            EngineView(engineSize, model: model)
            MoveListView(moveListSize, model: model)
            Spacer()
            NavigationView(navigationSize, model: model)
        }
    }
}

#Preview {
    ControlView(CGSize(width: 200, height: 500), model: ControlModel())
}



