import SwiftUI

struct EngineView: View {
    
    var lines:[EngineLine]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(lines) { x in
                Text("\(x.score) \(x.line)")
                    .lineLimit(1)
            }
        }
        .padding(5)
    }
}
