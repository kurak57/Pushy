import SwiftUI

struct RepetitionCounterDisplay: View {
    let repetitionCount: Int
    let actionLabel: String
    let confidenceLabel: String

    @State private var previousValue: Int = 0
    @State private var animate = false

    var body: some View {
        VStack(alignment: .center, spacing: 4) {

            Text(actionLabel)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text(confidenceLabel)
                .font(.caption)
                .foregroundColor(.white)
            Text("Repetition")
                .font(.title2)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .background(Color.black)
                .cornerRadius(4)

            // background
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black)
                    .frame(width: 50, height: 60)

                // Animation Number
                ZStack {
                    Text("\(previousValue)")
                        .font(
                            .system(
                                size: 40, weight: .bold, design: .monospaced)
                        )
                        .foregroundColor(.white)
                        .offset(y: animate ? -40 : 0)
                        .opacity(animate ? 0 : 1)

                    Text("\(repetitionCount)")
                        .font(
                            .system(
                                size: 40, weight: .bold, design: .monospaced)
                        )
                        .foregroundColor(.white)
                        .offset(y: animate ? 0 : 40)
                        .opacity(animate ? 1 : 0)
                        .scaleEffect(animate ? 1.05 : 1.0)
                        .animation(
                            .interpolatingSpring(stiffness: 500, damping: 15),
                            value: animate)
                }
            }

        }
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .padding(.top, 30) // Adjust based on top buttons
        .onChange(of: repetitionCount) { prevValue, newValue in
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animate = true
            }
        }
    }
}

#Preview {
    RepetitionCounterDisplay(
        repetitionCount: 2, actionLabel: "Observing...",
        confidenceLabel: "Observing...")
}
