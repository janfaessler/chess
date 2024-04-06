import SwiftUI

struct MoveView: View {
    let move:String
    let width:CGFloat
    
    init (_ move:String, width:CGFloat) {
        self.move = move
        self.width = width
    }
    var body: some View {
        Text(move)
            .frame(width: width, height: 20)
            .background(.gray)
    }
}

#Preview {
    MoveView("a2", width: 100)
}
