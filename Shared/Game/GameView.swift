
import SwiftUI

struct GameView: View {
    @ObservedObject var model:ControlModel
    
    init(_ game:PgnGame) {
        self.model = ControlModel(game)
    }

    var body: some View {
        GeometryReader{ geo in
            HStack(alignment: .top, spacing:0) {
                BoardView(model:model.board)
                    .frame(width: model.getBoardSize(geo),
                           height: model.getBoardSize(geo))
                ControlView(model: model)
               
            }
            .focusable()
            .focusEffectDisabled()
            .onKeyPress { press in
                Task {
                    await MainActor.run {
                        if press.key == .upArrow {
                            model.moveList.start()
                        }
                        if press.key == .rightArrow {
                            model.moveList.forward()
                        }
                        if press.key == .leftArrow {
                             model.moveList.back()
                        }
                        if press.key == .downArrow {
                            model.moveList.end()
                        }
                    }
                }
                return .handled
            }
        }
        
    }
    
}
