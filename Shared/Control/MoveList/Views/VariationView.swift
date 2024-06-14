import SwiftUI

struct VariationView: View {
    @ObservedObject var model:MoveListModel
    @ObservedObject var move:MoveContainer
    
    var body: some View {
        if hasVariations(move) {
            VStack {
                ForEach(getVariations(move), id: \.self) { variation in
                    Text(variation)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func hasVariations(_ container:MoveContainer?) -> Bool {
        container?.variations.count ?? 0 > 0
    }
    
    func getVariations(_ container:MoveContainer?) -> [String] {
        var variations:[String] = []
        for v in container!.variations.values {
            variations.append(Array(v).map({ "\($0.moveNumber). \(getMove($0.white))\($0.white == nil ? "..." : "")\($0.black != nil ? ", " : "")\(getMove($0.black))"  }).joined(separator: " "))
        }
        return variations
    }
    
    func getMove(_ container:MoveContainer?) -> String {
        guard let moveContainer = container else { return "" }
        var moveString:String = moveContainer.move.info()
        
        if moveContainer.variations.count > 0 {
            let variations = getVariations(moveContainer)
            for variation in variations {
                moveString.append(" (\(variation))")
            }
        }
        
        return moveString
    }
}
