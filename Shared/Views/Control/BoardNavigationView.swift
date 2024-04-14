import SwiftUI

struct BoardNavigationView: View {
    
    var model:ControlModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ControlButtonView("arrow.backward.to.line", shortcut: .downArrow) {
                model.start()
            }
            ControlButtonView("arrow.backward", shortcut: .leftArrow) {
                model.back()
            }
            ControlButtonView("arrow.forward", shortcut: .rightArrow) {
                model.forward()
            }
            ControlButtonView("arrow.forward.to.line", shortcut: .upArrow) {
                model.end()
            }
        }
        .frame(height: 30)
    }
}

#Preview {
    BoardNavigationView(model: ControlModel())
}
