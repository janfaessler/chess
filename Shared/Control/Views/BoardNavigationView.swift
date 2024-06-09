import SwiftUI

struct BoardNavigationView: View {
    
    var model:ControlModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ControlButtonView("arrow.backward.to.line", shortcut: .downArrow) {
                model.moves.start()
            }
            ControlButtonView("arrow.backward", shortcut: .leftArrow) {
                model.moves.back()
            }
            ControlButtonView("arrow.forward", shortcut: .rightArrow) {
                model.moves.forward()
            }
            ControlButtonView("arrow.forward.to.line", shortcut: .upArrow) {
                model.moves.end()
            }
        }
        .frame(height: 30)
    }
}

#Preview {
    BoardNavigationView(model: ControlModel())
}
