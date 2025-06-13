//
//  StepProgressView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct StepComponent: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        GeometryReader { geo in
            let circleDiameter: CGFloat = 36
            let spacing: CGFloat = 0
            let totalSpacing = CGFloat(totalSteps - 1) * spacing
            let availableWidth = geo.size.width - (CGFloat(totalSteps+1) * circleDiameter) - totalSpacing
            let segmentWidth = availableWidth / CGFloat(max(totalSteps - 1, 1))
            let progressWidth = max(0, CGFloat(currentStep) * (segmentWidth + circleDiameter) + circleDiameter / 2)
            

            ZStack(alignment: .leading) {
                // Background Bar
                Capsule()
                    .fill(Color.defaultCircle)
                    .frame(height: 24)

                // Progress Bar
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.A, Color.B]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressWidth+circleDiameter, height: 24)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)

                // Step Circles
                HStack(spacing: segmentWidth) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        ZStack {
                            Circle()
                                .fill(circleFillColor(for: index))
                                .frame(width: circleDiameter, height: circleDiameter)

                            Text("\(index+1)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                }
                .frame(width: availableWidth, alignment: .leading)
                .padding(.leading, circleDiameter)
            }
        }
        .frame(height: 44)
    }

    private func circleFillColor(for index: Int) -> Color {
        switch currentStep {
        case 0:
            return index == 0 ? .B : .defaultCircle
        case 1:
            if index == 0 { return .circle1 }
            else if index == 1 { return .B }
            else { return .defaultCircle }
        case 2:
            if index == 0 { return .circle2 }
            else if index == 1 { return .circle3 }
            else if index == 2 { return .B }
            else { return .defaultCircle }
        default:
            return .defaultCircle
        }
    }
}

#Preview {
    StepComponent(totalSteps: 3, currentStep: 2)
}
