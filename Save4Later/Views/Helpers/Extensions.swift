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
