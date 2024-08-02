import SwiftUI

struct CommentView: View {
    @ObservedObject var model:ControlModel
    
    var body: some View {
        Text(getCommentText())
    }
    func getCommentText() -> String {

        guard let currentMove = model.moveList.currentMove else {
            return model.game?.comment ?? ""
        }
        
        return currentMove.note ??  ""
    }
}
