import SwiftUI

struct ControlView: View {
    let size:CGSize
    
    @ObservedObject var model:ControlModel
    
    init (_ size:CGSize, model:ControlModel) {
        self.size = size
        self.model = model
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            MoveListView(size, model: model)
            Spacer()
            
            HStack(alignment: .center, spacing: 0) {
                ControlButtonView("|<", shortcut: .downArrow, size: CGSize(width: size.width / 5, height: 30)) {
                    model.start()
                }
                ControlButtonView("<", shortcut: .leftArrow, size: CGSize(width: size.width / 4, height: 30)) {
                    model.back()
                }
                ControlButtonView(">", shortcut: .rightArrow, size: CGSize(width: size.width / 4, height: 30)) {
                    model.forward()
                }
                ControlButtonView(">|", shortcut: .upArrow, size: CGSize(width: size.width / 4, height: 30)) {
                    model.end()
                }
            }
            .frame(width: size.width, height: 30)
        }
    }
        
}

#Preview {
    ControlView(CGSize(width: 200, height: 500), model: ControlModel())
}

