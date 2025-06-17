import SwiftUI

struct PositionFeedbackView: View {
    let feedback: String
    let isInCorrectPosition: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Text(feedback)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(isInCorrectPosition ? .green : .white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if isInCorrectPosition {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(12)
        .animation(.easeInOut, value: isInCorrectPosition)
    }
}

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 20) {
            PositionFeedbackView(
                feedback: "Level your shoulders",
                isInCorrectPosition: false
            )
            PositionFeedbackView(
                feedback: "Perfect position!",
                isInCorrectPosition: true
            )
        }
    }
} 