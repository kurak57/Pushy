import SwiftUI

struct TopControlButtons: View {
    @Binding var isPresented: Bool
    let resetAction: () -> Void
    var isExerciseActive: Bool
    var isSessionCompleted: Bool
    var repetitionCount: Int

    var body: some View {
        ZStack {
            if isExerciseActive && !isSessionCompleted {
                RepetitionCounterDisplay(
                    repetitionCount: repetitionCount
                )
                .padding(.top, 65 )
            }
            HStack {
                Button(action: {
                    self.isPresented.toggle()
                }) {
                    Image(systemName: "multiply")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: resetAction) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                Button(action: {
                    // Speaker action
                }) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
        }
//        .background(Color.black)
        .frame(maxWidth: .infinity, minHeight: 160)
    }
}

#Preview {
    TopControlButtons(isPresented: .constant(true), resetAction: { }, isExerciseActive: true, isSessionCompleted: false, repetitionCount: 4)
}
