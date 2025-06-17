import SwiftUI

struct ExerciseControlButtons: View {
    let finishAction: () -> Void

    var body: some View {
        VStack {
            Spacer()
            Button(action: finishAction) {
                Text("Finish Exercise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
            .padding(.bottom, 50)
        }
    }
}

#Preview {
    ExerciseControlButtons(finishAction: { print("Finish Exercise tapped!") })
}
