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
    /// App-wide accent: rich indigo
    static let s4lAccent = Color(red: 0.33, green: 0.27, blue: 0.90)
    static let s4lAccentLight = Color(red: 0.33, green: 0.27, blue: 0.90).opacity(0.12)
}
