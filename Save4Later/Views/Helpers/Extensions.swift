import SwiftUI

extension String {
    var titleCased: String {
        return self
            .lowercased()
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

extension String {
    var pluralize: String {
        return "\(self)s"
    }
}

extension Color {
    /// App-wide accent: deep red / brick
    static let s4lAccent = Color(red: 0.651, green: 0.235, blue: 0.184)  // #A63C2F
    static let s4lAccentLight = Color(red: 0.651, green: 0.235, blue: 0.184).opacity(0.12)

    /// Primary background: sandy tan (light) / deep navy (dark)
    static let s4lBackground = Color(uiColor: UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.051, green: 0.086, blue: 0.157, alpha: 1) // #0D1628
            : UIColor(red: 0.941, green: 0.886, blue: 0.753, alpha: 1) // #F0E2C0
    })

    /// Secondary background: slightly deeper shade for cards / input fields
    static let s4lSecondaryBackground = Color(uiColor: UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.086, green: 0.125, blue: 0.212, alpha: 1) // #162035
            : UIColor(red: 0.902, green: 0.831, blue: 0.659, alpha: 1) // #E6D4A8
    })
}
