import SwiftUI

struct ResultView: View {
    
    let model:ResultModel

    var body: some View {
        if model.shouldDisplay() {
            ZStack {
                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30))
                    .fill(.background)
                VStack {
                    Text(model.getResultText())
                        .bold()
                        .font(.largeTitle)
                    if model.shouldDisplayExplenation() {
                        Text(model.getExplenation())
                    }
                }
            }.frame(width: 200, height: 75)
                .shadow(radius: 10)
        }
    }
}

#Preview {
    ResultView(model: ResultModel(.DrawBy50MoveRule))
}
