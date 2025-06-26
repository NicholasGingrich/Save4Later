import SwiftUI

struct ContentView: View {
    @Environment(ModelData.self) private var modelData

    var body: some View {
       SavedItemsHome()
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
