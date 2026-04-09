import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var modelData = ModelData()
    @State private var scale: CGFloat = 0.3
    @State private var offsetX: CGFloat = 0
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if isActive {
                ContentView()
                    .environment(modelData)
            } else {
            GeometryReader { geometry in
                VStack {
                    Image(colorScheme == .dark ? "4L-dark-bg-variant" : "4L-light-bg-variant")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 325)
                        .padding()
                        .padding(.bottom, 105)
                        .scaleEffect(scale)
                        .offset(x: offsetX)
                        .onAppear {
                            withAnimation(.smooth()) {
                                scale = 1.0
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    offsetX = -geometry.size.width
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                                withAnimation {
                                    isActive = true
                                }
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.s4lBackground)
            }
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                modelData.importSharedItemIfAvailable()
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .font(.custom("OpenSans-Regular", size: 16))
}
