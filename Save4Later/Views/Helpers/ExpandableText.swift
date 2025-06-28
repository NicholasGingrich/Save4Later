import SwiftUI

struct ExpandableText: View {
    let text: String
    @State private var expanded: Bool = false
    @State private var shouldShowButton = false
    @State private var fullHeight: CGFloat = 0
    @State private var twoLineHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(.subheadline)
                .padding(.leading)
                .padding(.top, 0.1)
                .lineLimit(expanded ? nil : 2)
                .animation(.easeInOut, value: expanded)
                .background(
                    GeometryReader { geo -> Color in
                        DispatchQueue.main.async {
                            if expanded {
                                fullHeight = geo.size.height
                            } else {
                                twoLineHeight = geo.size.height
                                shouldShowButton = fullHeight > twoLineHeight
                            }
                        }
                        return Color.clear
                    }
                )

            if shouldShowButton {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            expanded.toggle()
                        }
                    }) {
                        Text(expanded ? "See Less" : "See More")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            // Run both expanded and collapsed layouts once to capture heights
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expanded = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    expanded = false
                }
            }
        }
    }
}


#Preview {
    ExpandableText(text: "This is some sample text to see if the expandable text thing actually works. But lets add some more text adn see if it collapses.")
}
