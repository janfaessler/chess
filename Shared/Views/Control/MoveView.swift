import SwiftUI

struct MoveView: View {
    
    let model:ControlModel
    let index:Int
    let action: () -> Void
    
    var body: some View {
        
        Button {
            model.goToMove(index + 1)
        } label: {
            Text(model.getMoveDescription(index))
                .fontWeight(model.isCurrentMove(index) ? .bold : .regular)
                .padding(3)
                .frame(maxWidth: .infinity)
                .background(model.isCurrentMove(index)  ? .gray.opacity(0.5) : .gray)
        }.buttonStyle(.plain)
    
    }
}
