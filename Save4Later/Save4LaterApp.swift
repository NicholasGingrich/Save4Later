import SwiftUI

@main
struct Save4LaterApp: App {
    @State private var modelData = ModelData()

    init() {
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

