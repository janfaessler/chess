import SwiftUI

struct MoveView: View {
    
    let model:MoveListModel
    let move:MoveContainer
    let action: () -> Void
    
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(move.move.info())
                .fontWeight(model.isCurrentMove(move) ? .bold : .regular)
                .padding(3)
                .frame(maxWidth: .infinity)
                .background(model.isCurrentMove(move)  ? .gray.opacity(0.5) : .gray)
        }.buttonStyle(.plain)
    
    }
}
