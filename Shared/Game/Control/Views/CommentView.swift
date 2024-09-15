import SwiftUI

struct CommentView: View {
    @ObservedObject var model:ControlModel
    
    var body: some View {
        GroupBox(label:Text("Note")) {
            Text(model.comment)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
    }
}
