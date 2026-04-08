import SwiftUI

@main
struct Save4LaterApp: App {
    @State private var modelData = ModelData()

    init() {
        // Apply OpenSans to navigation bar titles globally
        if let largeTitleFont = UIFont(name: "OpenSans-Bold", size: 34) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .font: largeTitleFont
            ]
        }
        if let inlineTitleFont = UIFont(name: "OpenSans-SemiBold", size: 17) {
            UINavigationBar.appearance().titleTextAttributes = [
                .font: inlineTitleFont
            ]
        }
        // Let SwiftUI List / Form show our custom background instead of the system white/black
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .font(.custom("OpenSans-Regular", size: 16))
        }
    }
}

