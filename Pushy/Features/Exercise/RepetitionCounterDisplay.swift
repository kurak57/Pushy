import SwiftUI

struct RepetitionCounterDisplay: View {
    let repetitionCount: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("Repetition")
                .font(.headline)
                .bold()
            Text("\(repetitionCount)")
                .font(.largeTitle)
                .bold()
                .id(repetitionCount)
                .contentTransition(.numericText(value: Double(repetitionCount)))
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .padding(.top, 70) // Adjust based on top buttons
    }
}

#Preview {
    RepetitionCounterDisplay(repetitionCount: 2)
} 