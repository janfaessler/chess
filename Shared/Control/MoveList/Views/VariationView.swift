import SwiftUI

struct VariationView: View {
    var model:MoveListModel
    var variation:LineModel
    var name:String
    @State private var isDisclosed = false

    
    var body: some View {
        VStack {
            Button(name) {
                   withAnimation {
                       isDisclosed.toggle()
                   }
               }
               .buttonStyle(.plain)
            ZStack {
                Rectangle()
                    .foregroundColor(.black)
                    .border(.white)
                    .clipShape(.rect(cornerRadius: 10))
                LineView(model: model, line: variation.all)
                    .padding(10)
            }
            .frame(height: isDisclosed ? nil : 0, alignment: .top)
            .clipped()
        }
        
    }
}
