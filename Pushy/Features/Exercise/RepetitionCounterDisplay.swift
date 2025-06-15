import SwiftUI

struct RepetitionCounterDisplay: View {
    let repetitionCount: Int
    let actionLabel: String
    let confidenceLabel: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(actionLabel)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            Text(confidenceLabel)
                .font(.caption)
                .foregroundColor(.white)
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
    RepetitionCounterDisplay(repetitionCount: 2, actionLabel: "Observing...", confidenceLabel: "Observing...")
}
