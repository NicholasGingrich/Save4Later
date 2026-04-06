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
            .font(.custom("OpenSans-Regular", size: 16))
    }
}

#Preview {
    ContentView()
        .environment(ModelData())
        .font(.custom("OpenSans-Regular", size: 16))
}
