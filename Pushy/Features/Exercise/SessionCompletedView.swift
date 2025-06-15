import SwiftUI

struct SessionCompletedView: View {
    let totalSets: Int
    let totalReps: Int
    let dismissAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Session\ncompleted")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .bold()
                .foregroundColor(.white)
            Image("Check")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 225, height: 225)
            Text("Goals")
                .font(.title2)
                .bold()
                .foregroundColor(.gray)
            Text("\(totalSets) sets of \(totalReps) repetitions")
                .font(.title)
                .bold()
                .foregroundColor(.white)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                dismissAction()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.25, green: 0.1, blue: 0.4), Color(red: 0, green: 0, blue: 0), Color(red: 0.1, green: 0.3, blue: 0.25)]), startPoint: .top, endPoint: .bottom))
        .ignoresSafeArea()
    }
        
}

#Preview {
    SessionCompletedView(totalSets: 3, totalReps: 5, dismissAction: { print("Dismiss") })
} 
