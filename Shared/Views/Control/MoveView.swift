import SwiftUI

struct MoveView: View {
    let move:String
    let width:CGFloat
    let highlight:Bool
    
    init (_ move:String, width:CGFloat, highlight:Bool) {
        self.move = move
        self.width = width
        self.highlight = highlight
    }
    var body: some View {
        Text(move)
            .fontWeight(highlight ? .bold : .regular)
            .frame(width: width, height: 20)
            .background(highlight ? .gray.opacity(0.5) : .gray)
    }
}

#Preview {
    MoveView("a2", width: 100, highlight: false)
}
