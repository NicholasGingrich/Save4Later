import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var modelData = ModelData()
    @State private var scale: CGFloat = 0.3
    @State private var offsetX: CGFloat = 0

    var body: some View {
        if isActive {
            ContentView()
                .environment(modelData)
        } else {
            GeometryReader { geometry in
                VStack {
                    Image("4L")
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
                .background(Color.black)
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .font(.custom("OpenSans-Regular", size: 16))
}
