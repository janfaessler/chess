import SwiftUI

struct MoveView: View {
    let action: () -> Void
    let move:String
    let width:CGFloat
    let highlight:Bool
    
    init (_ move:String, width:CGFloat, highlight:Bool, action: @escaping  () -> Void) {
        self.move = move
        self.width = width
        self.highlight = highlight
        self.action = action
    }
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(move)
                .fontWeight(highlight ? .bold : .regular)
                .frame(width: width, height: 20)
                .background(highlight ? .gray.opacity(0.5) : .gray)
        }.buttonStyle(.plain)
        

    }
}

#Preview {
    MoveView("a2", width: 100, highlight: false) {}
}
