import SwiftUI

struct ControlButtonView: View {
    let action: () -> Void
    let label:String
    let shortcut:KeyEquivalent

    init(_ label:String, shortcut:KeyEquivalent, action: @escaping  () -> Void) {
        self.action = action
        self.label = label
        self.shortcut = shortcut
    }
    var body: some View {
        Button { action() } label: {
            Image(systemName: label)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    ControlButtonView("arrow.backward.to.line", shortcut: .downArrow) {}
}
