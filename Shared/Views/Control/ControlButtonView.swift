import SwiftUI

struct ControlButtonView: View {
    let action: () -> Void
    let size:CGSize
    let label:String
    let shortcut:KeyEquivalent

    init(_ label:String, shortcut:KeyEquivalent, size:CGSize, action: @escaping  () -> Void) {
        self.action = action
        self.size = size
        self.label = label
        self.shortcut = shortcut
    }
    var body: some View {
        Button { action() } label: {
            Text(label)
                .frame(width: size.width, height: size.height)
                .cornerRadius(0)
                .background(.gray)
                .fontWeight(.heavy)
                .fontDesign(.monospaced)
                .border(.black)
        }
        .buttonStyle(.plain)
        .keyboardShortcut(shortcut, modifiers: [])
    }
}

#Preview {
    ControlButtonView("|<", shortcut: .downArrow, size: CGSize(width: 30, height: 30)) {}
}
