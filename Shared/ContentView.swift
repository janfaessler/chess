import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader{ geo in
            BoardView(getFieldSize(geo))
        }
    }
    
    func getFieldSize(_ geo:GeometryProxy) -> CGFloat {
        return min(geo.size.width, geo.size.height) / 8
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
