import SwiftUI

struct BoardNavigationView: View {
    
    var model:ControlModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ControlButtonView("arrow.backward.to.line", shortcut: .downArrow) {
                model.moveList.start()
            }
            ControlButtonView("arrow.backward", shortcut: .leftArrow) {
                model.moveList.back()
            }
            ControlButtonView("arrow.forward", shortcut: .rightArrow) {
                model.moveList.forward()
            }
            ControlButtonView("arrow.forward.to.line", shortcut: .upArrow) {
                model.moveList.end()
            }
        }
        .frame(height: 30)
    }
}

#Preview {
    BoardNavigationView(model: ControlModel())
}
