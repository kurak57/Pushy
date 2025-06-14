import SwiftUI

struct TopControlButtons: View {
    @Binding var isPresented: Bool

    var body: some View {
        HStack {
            Button(action: {
                self.isPresented.toggle()
            }) {
                Image(systemName: "multiply")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            Spacer()
            Button(action: {
                // Speaker action
            }) {
                Image(systemName: "speaker.wave.2")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

#Preview {
    TopControlButtons(isPresented: .constant(true))
} 