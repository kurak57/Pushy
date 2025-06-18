//
//  InformationView.swift
//  Pushy
//
//  Created by Andrea Octaviani on 18/06/25.
//

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
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Image("mascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                    Text("Quick Heads-Up")
                        .font(.roundedmplus(size: 28))
                        .bold()
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                
                // Card
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(infoItems) { item in
                        InformationItem(item: item)
                    }
                }
                .padding()
                .background(Color.bgPurple40.opacity(0.4))
                .cornerRadius(24)
                .padding()
                
                Spacer()
                
                // Button
                Button(action: {
                    // Dismiss or navigate
                    onFinish()
                }) {
                    Text("Got it")
                        .font(.roundedmplus(size: 20))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.bottom)
                .shadow(color: .gray, radius: 0, x: 0, y: 4)
            }
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: .bgPurple40, location: 0.00),
                        Gradient.Stop(color: .black, location: 0.20),
                        Gradient.Stop(color: .black, location: 1.00)
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 1)
                )
            )
        }
    }
}

//#Preview {
//    InformationView(onFinish: {
//        hasSeenFeatureInfo = true
//    })
//        
//}
