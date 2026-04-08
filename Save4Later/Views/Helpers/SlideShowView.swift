import SwiftUI

struct SlideshowView: View {
    @Environment(ModelData.self) private var modelData
    @State private var currentImage: Image? = nil
    @State private var currentItem: SavedItem? = nil
    @State private var timer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()

    private let cardHeight: CGFloat = 230


    var body: some View {
        Group {
            if let item = currentItem {
                NavigationLink {
                    SavedItemDetail(initialItem: item)
                } label: {
                    slideshowCard
                }
                .buttonStyle(.plain)
            } else {
                slideshowCard
            }
        }
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
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

    @ViewBuilder
    private var slideshowCard: some View {
        ZStack(alignment: .bottomLeading) {
            if let image = currentImage {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
                    .clipped()
                    .transition(.opacity)
            } else {
                LinearGradient(
                    colors: [Color.s4lAccent.opacity(0.4), Color.s4lAccent.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
            }

            if let item = currentItem {
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.category.uppercased())
                        .font(.custom("OpenSans-Regular", size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.8))
                        .tracking(1.2)

                    Text(item.name)
                        .font(.custom("OpenSans-Regular", size: 18))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .environment(\.colorScheme, .dark)
                        .opacity(0.55)
                )
                .padding(14)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, minHeight: cardHeight, maxHeight: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .contentShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.s4lAccent.opacity(0.25), radius: 16, x: 0, y: 8)
    }
}

#Preview {
    SlideshowView()
        .environment(ModelData())
}
