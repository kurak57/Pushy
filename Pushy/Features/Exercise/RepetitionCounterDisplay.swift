import SwiftUI

struct RepetitionCounterDisplay: View {
    let repetitionCount: Int

    @State private var previousValue: Int = 0
    @State private var animate = false

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("Repetition")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .cornerRadius(4)
            // Animated Number
            ZStack {
                Text("\(previousValue)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .offset(y: animate ? -40 : 0)
                    .opacity(animate ? 0 : 1)

                Text("\(repetitionCount)")
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .offset(y: animate ? 0 : 40)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1.05 : 1.0)
                    .animation(.interpolatingSpring(stiffness: 500, damping: 15), value: animate)
            }
        }
        .frame(maxWidth: .infinity)
//        .background(Color.black)
//        .padding(.top, 30)
        .onChange(of: repetitionCount) { old, new in
            previousValue = old
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animate = true
            }
        }
    }
}

#Preview {
    RepetitionCounterDisplay(
        repetitionCount: 2
    )
}
