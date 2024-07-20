import SwiftUI

struct GamesView: View {
    @ObservedObject var model:ControlModel

    var body: some View {
        ScrollView {
            LazyVStack{
                ForEach(model.games) { game in
                    ZStack {
                        Button {
                            model.openGame(game)
                        } label: {
                            Text(game.getTitle())
                                .fontWeight(.regular)
                                .padding(3)
                                .frame(maxWidth: .infinity)
                                .background(.gray.opacity(0.5))
                        }.buttonStyle(.plain)
                    
                    }
                }
            }
        }
    }
}
