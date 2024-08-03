import SwiftUI

struct VariationView: View {
    var model:MoveListModel
    var variation:LineModel
    var name:String
    @State private var isDisclosed = false

    
    var body: some View {
        VStack {
            HStack {
                Text("\(variation.variationStartNumber).")
                if variation.first?.color == .black {
                    Rectangle().fill(.clear)
                }
                MoveView(model: model, move: variation.first!) {
                    withAnimation {
                        isDisclosed.toggle()
                    }
                }
                if variation.first?.color == .white {
                    Rectangle().fill(.clear)
                }
            }.padding(5)
           
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
