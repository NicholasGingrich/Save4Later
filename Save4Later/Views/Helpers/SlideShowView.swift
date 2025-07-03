import SwiftUI

struct SlideshowView: View {
    @Environment(ModelData.self) private var modelData
    @State private var currentImage: Image? = nil
    @State private var timer = Timer.publish(every: 3.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            if let image = currentImage {
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity)
            } else {
                Color.gray.opacity(0.2) // fallback if no images
            }
        }
        .frame(height: 200)
        .cornerRadius(10)
        .clipped()
        .padding()
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onAppear {
            pickRandomImage()
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                pickRandomImage()
            }
        }
    }

    private func pickRandomImage() {
        guard !modelData.savedItems.isEmpty else {
            currentImage = nil
            return
        }

        currentImage = modelData.savedItems.randomElement()?.previewImage
    }
}

#Preview {
    SlideshowView()
        .environment(ModelData())
}
