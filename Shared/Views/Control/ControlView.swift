import SwiftUI

struct ControlView: View {
    let size:CGSize
    
    @ObservedObject var model:ControlModel
    
    init (_ size:CGSize, model:ControlModel) {
        self.size = size
        self.model = model
    }
    
    var body: some View {

        MoveListView(size, model: model)
            .frame(width: size.width, height: size.height)
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    ControlButtonView("|<", shortcut: .downArrow, size: CGSize(width: size.width / 4, height: 30)) {
                        model.start()
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    ControlButtonView("<", shortcut: .leftArrow, size: CGSize(width: size.width / 4, height: 30)) {
                        model.back()
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    ControlButtonView(">", shortcut: .rightArrow, size: CGSize(width: size.width / 4, height: 30)) {
                        model.forward()
                    }
                }
                ToolbarItem(placement: .secondaryAction) {
                    ControlButtonView(">|", shortcut: .upArrow, size: CGSize(width: size.width / 4, height: 30)) {
                        model.end()
                    }
                }
            }
    }
}

#Preview {
    ControlView(CGSize(width: 200, height: 500), model: ControlModel())
}

