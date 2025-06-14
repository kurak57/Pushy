import SwiftUI

struct PositionGuideView: View {
    let geo: GeometryProxy

    var body: some View {
        VStack {
            Spacer()
            Image("PositionGuide")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.8)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            Color.green,
                            lineWidth: 3
                        )
                )
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .center, vertical: .bottom))
    }
}

#Preview {
    GeometryReader { geo in
        PositionGuideView(geo: geo)
    }
} 