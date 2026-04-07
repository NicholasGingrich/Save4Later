import SwiftUI

struct SlideshowView: View {
    @Environment(ModelData.self) private var modelData
    @State private var currentImage: Image? = nil
    @State private var currentItem: SavedItem? = nil
    @State private var timer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()

    private let cardHeight: CGFloat = 230

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                // Background — sized explicitly so scaledToFill knows both dimensions
                if let image = currentImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: cardHeight)
                        .clipped()
                        .transition(.opacity)
                } else {
                    LinearGradient(
                        colors: [Color.s4lAccent.opacity(0.4), Color.s4lAccent.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: geo.size.width, height: cardHeight)
                }

                // Gradient scrim
                LinearGradient(
                    colors: [.clear, .black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geo.size.width, height: cardHeight)

                // Item info overlay
                if let item = currentItem {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.category.uppercased())
                            .font(.custom("OpenSans-Regular", size: 10))
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1.2)

                        Text(item.name)
                            .font(.custom("OpenSans-Regular", size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(18)
                    .transition(.opacity)
                }
            }
            .frame(width: geo.size.width, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.s4lAccent.opacity(0.25), radius: 16, x: 0, y: 8)
        }
        .frame(height: cardHeight)
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .onAppear { pickRandomItem() }
        .onDisappear { timer.upstream.connect().cancel() }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                pickRandomItem()
            }
        }
    }

    private func pickRandomItem() {
        guard !modelData.savedItems.isEmpty else {
            currentImage = nil
            currentItem = nil
            return
        }
        let item = modelData.savedItems.randomElement()
        currentItem = item
        currentImage = item?.previewImage
    }
}

#Preview {
    SlideshowView()
        .environment(ModelData())
}
