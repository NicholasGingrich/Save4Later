import SwiftUI

struct RoundedImage: View {
    var image: Image
    
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill) 
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 7)
    }
}

#Preview {
    RoundedImage(image: Image("Mushroom-Risotto-1"))
}
