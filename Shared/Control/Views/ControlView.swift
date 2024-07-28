import SwiftUI
import FilePicker

struct ControlView: View {
    
    @ObservedObject var model:ControlModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            GamesView(model: model)
            EngineView(lines: model.lines)
            Text(getCommentText())
            MoveListView(model: model.moveList)
            Spacer()
            BoardNavigationView(model: model)
        }
    }
    
    func getCommentText() -> String {

        guard let currentMove = model.moveList.currentMove else {
            return model.game?.comment ?? ""
        }
        
        return currentMove.note ??  ""
    }
}

