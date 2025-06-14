import SwiftUI

struct SessionCompletedView: View {
    let totalSets: Int
    let totalReps: Int
    let dismissAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Session completed")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(Color.green)
            Text("Goals")
                .font(.headline)
                .foregroundColor(.gray)
            Text("\(totalSets) sets of \(totalReps) repetitions")
                .font(.title2)
                .foregroundColor(.white)
            Button(action: dismissAction) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.8))
        .ignoresSafeArea()
    }
}

#Preview {
    SessionCompletedView(totalSets: 3, totalReps: 5, dismissAction: { print("Dismiss") })
} 