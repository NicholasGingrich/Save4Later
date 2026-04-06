import SwiftUI

struct ContentView: View {
    @Environment(ModelData.self) private var modelData

    var body: some View {
        SavedItemsHome()
            .font(.custom("OpenSans-Regular", size: 16))
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
        .font(.custom("OpenSans-Regular", size: 16))
}
