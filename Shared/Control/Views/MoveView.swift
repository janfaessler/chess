import SwiftUI

struct MoveView: View {
    
    let model:MoveListModel
    let id:UUID
    let action: () -> Void
    
    var body: some View {
        
        Button {
            action()
        } label: {
            Text(model.getMoveDescription(id))
                .fontWeight(model.isCurrentMove(id) ? .bold : .regular)
                .padding(3)
                .frame(maxWidth: .infinity)
                .background(model.isCurrentMove(id)  ? .gray.opacity(0.5) : .gray)
        }.buttonStyle(.plain)
    
    }
}
