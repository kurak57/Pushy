import SwiftUI

struct InformationView: View {
    
    let onFinish: () -> Void
    
    private let infoItems: [InformationModel] = [
        .init(icon: "💪", title: "Track Bicep Curls Only", message: "For now, the app is built just for bicep curls—works best in bright, open spaces."),
        .init(icon: "🔍", title: "Still Learning", message: "The system isn’t perfect. It may miss reps now and then, especially in tricky setups."),
        .init(icon: "✅", title: "What We Check", message: "We count clean reps. You’ll get tips if your elevated elbow or you lean back."),
        .init(icon: "🎯", title: "You’re in Control", message: "We guide. You move. Go at your own pace.")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 0) {
                        Image("mascot")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        Text("Quick Heads-Up")
                            .font(.roundedmplus(size: 28))
                            .bold()
                            .foregroundColor(.white)
                    }

                    // Card
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(infoItems) { item in
                            InformationItem(item: item)
                        }
                    }
                    .padding(16)
                    .background(Color.bgPurple40.opacity(0.4))
                    .cornerRadius(24)
                    Spacer()
                }
                .padding(.horizontal, 16)

                // Button
                VStack {
                    Spacer()
                    Button {
                        onFinish()
                    } label: {
                        Text("Got it")
                            .font(.roundedmplus(size: 17))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                    .shadow(color: .gray, radius: 0, x: 0, y: 4)
                }
            }
            .background(
                LinearGradient(
                    stops: [
                        .init(color: .bgPurple40, location: 0.0),
                        .init(color: .black, location: 0.2),
                        .init(color: .black, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

#Preview {
    InformationView {
        print("Dismissed")
    }
}
