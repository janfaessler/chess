import SwiftUI

struct VariationView: View {
    @ObservedObject var move:MoveContainer
    
    var body: some View {
        if hasVariations(move) {
            ForEach(getVariations(move), id: \.self) { variation in
                Text(variation)
            }
        }   
    }
    
    func hasVariations(_ container:MoveContainer?) -> Bool {
        container?.variations.count ?? 0 > 0
    }
    
    func getVariations(_ container:MoveContainer?) -> [String] {
        var variations:[String] = []
        for v in container!.variations.values {
            variations.append(Array(v).map({ $0.move.info() }).joined(separator: ","))
        }
        return variations
    }
}
