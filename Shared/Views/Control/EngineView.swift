import SwiftUI

struct EngineView: View {
    
    let size:CGSize
    var model:[EngineLine]
    
    init (_ size:CGSize, model:[EngineLine]) {
        self.size = size
        self.model = model.sorted(by: { $0.id < $1.id })
    }
    var body: some View {
        VStack  {
            ForEach(model) { x in
                Text("\(x.score) \(x.line)")
                    .frame(width: size.width, alignment: .leading)
                    
                
            }
        }
        .frame(width: size.width)
        .padding()

    }
}
