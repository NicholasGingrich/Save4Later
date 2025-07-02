import SwiftUI

struct ContentView: View {
    @Environment(ModelData.self) private var modelData
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
       SavedItemsHome()
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    modelData.importSharedItemIfAvailable()
                }
            }
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
}
