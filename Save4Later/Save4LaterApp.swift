import SwiftUI

@main
struct Save4LaterApp: App {
    @State private var modelData = ModelData()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .font(.custom("OpenSans-Regular", size: 16)) // Adjust as needed
        }
    }
}

