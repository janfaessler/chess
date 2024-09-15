import SwiftUI

struct BoardNavigationView: View {
    
    var model:ControlModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ControlButtonView("arrow.backward.to.line", shortcut: .downArrow) {
                Task {
                  await model.moveList.start()
                }
            }
            ControlButtonView("arrow.backward", shortcut: .leftArrow) {
                Task {
                  await model.moveList.back()
                }
            }
            ControlButtonView("arrow.forward", shortcut: .rightArrow) {
                Task {
                  await model.moveList.forward()
                }            }
            ControlButtonView("arrow.forward.to.line", shortcut: .upArrow) {
                Task {
                  await model.moveList.end()
                }
            }
        }
        .frame(height: 30)
    }
}
