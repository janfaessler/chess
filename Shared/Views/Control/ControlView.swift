import SwiftUI

struct ControlView: View {
    let size:CGSize
    let navigationSize:CGSize
    let moveListSize:CGSize
    
    @ObservedObject var model:ControlModel
    
    init (_ size:CGSize, model:ControlModel) {
        self.size = size
        self.model = model
        self.navigationSize = CGSize(width: size.width, height: 30)
        self.moveListSize = CGSize(width: size.width, height: size.height - navigationSize.height)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            MoveListView(moveListSize, model: model)
            Spacer()
            NavigationView(navigationSize, model: model)
        }
    }
}

#Preview {
    ControlView(CGSize(width: 200, height: 500), model: ControlModel())
}



