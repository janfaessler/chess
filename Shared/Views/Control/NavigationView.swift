import SwiftUI

struct NavigationView: View {
    
    @ObservedObject var model:ControlModel
    let buttonSize:CGSize
    let size:CGSize
    
    init (_ size:CGSize, model:ControlModel) {
        self.buttonSize = CGSize(width: size.width / 4, height: size.height)
        self.model = model
        self.size = size
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ControlButtonView("arrow.backward.to.line", shortcut: .downArrow, size: buttonSize) {
                model.start()
            }
            ControlButtonView("arrow.backward", shortcut: .leftArrow, size: buttonSize) {
                model.back()
            }
            ControlButtonView("arrow.forward", shortcut: .rightArrow, size: buttonSize) {
                model.forward()
            }
            ControlButtonView("arrow.forward.to.line", shortcut: .upArrow, size: buttonSize) {
                model.end()
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

#Preview {
    NavigationView(CGSize(width: 200, height: 30), model: ControlModel())
}
