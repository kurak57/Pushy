import SwiftUI

struct GoalsInfoDisplay: View {
    let currentSet: Int
    let totalSets: Int
    let totalReps: Int
    let weight: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Goals")
                .font(.headline)
                .bold()
            Text("Set : \(currentSet)/\(totalSets)")
                .font(.subheadline)
            Text("Rep : \(totalReps)")
                .font(.subheadline)
            Text("Weight: \(weight, specifier: "%.1f") kg")
                .font(.subheadline)
        }
        .foregroundColor(.white)
        .padding()
        .background(Color.black.opacity(0.6))
        .cornerRadius(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .padding(.leading, 16)
        .padding(.bottom, 16)
    }
}

#Preview {
    GoalsInfoDisplay(currentSet: 1, totalSets: 3, totalReps: 5, weight: 10.5)
}
