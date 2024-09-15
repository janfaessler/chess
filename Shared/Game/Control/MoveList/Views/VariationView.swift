import SwiftUI

struct VariationView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var move:MoveModel
    @State var variation:String?
    var moveNumber:Int
    
    var body: some View {
        VStack {
            Picker(selection: $variation, label: EmptyView()) {
                ForEach(move.getVariations(), id: \.self) { variation in
                    Text(getName(variation)).tag(variation as String?)
                }
            }
            .pickerStyle(.segmented)
            .padding(5)
            
            if variation != nil {
                GroupBox(label:EmptyView()) {
                    LineView(model: model, line: move.getVariation(variation!)!)
                        .padding(10)
                }
            }
        }
    }
    
    func getName(_ variation:String) -> String {
        switch move.color {
        case .white:
            return "\(moveNumber). \(variation)"
        case .black:
            return "\(moveNumber)... \(variation)"
        }
    }
}
