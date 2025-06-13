//
//  StepProgressView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct StepProgressView: View {
    let totalSteps: Int
    let currentStep: Int

    var body: some View {
        GeometryReader { geo in
            let circleDiameter: CGFloat = 36
            let spacing: CGFloat = 0
            let totalSpacing = CGFloat(totalSteps - 1) * spacing
            let availableWidth = geo.size.width - (CGFloat(totalSteps) * circleDiameter) - totalSpacing
            let segmentWidth = availableWidth / CGFloat(max(totalSteps - 1, 1))
            let progressWidth = max(0, CGFloat(currentStep + 1) * (segmentWidth + circleDiameter) + circleDiameter / 2)

            ZStack(alignment: .leading) {
                // Background Bar
                Capsule()
                    .fill(Color.defaultCircle)
                    .frame(height: 24)

                // Progress Bar
                Capsule()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: progressWidth, height: 24)
                    .animation(.easeInOut(duration: 0.3), value: currentStep)

                // Step Circles
                HStack(spacing: segmentWidth) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        ZStack {
                            Circle()
                                .fill(circleFillColor(for: index))
                                .frame(width: circleDiameter, height: circleDiameter)
                                .opacity(index == 0 ? 0 : 1)

                            if index > 0 {
                                Text("\(index)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(height: 44)
        .padding(.horizontal)
    }

    private func circleFillColor(for index: Int) -> Color {
        guard index != 0 else { return .clear } // Circle pertama transparan

        switch currentStep {
        case 0:
            return index == 1 ? .B : .defaultCircle
        case 1:
            if index == 1 { return .circle1 }
            else if index == 2 { return .B }
            else { return .defaultCircle }
        case 2:
            if index == 1 { return .circle2 }
            else if index == 2 { return .circle3 }
            else if index == 3 { return .B }
            else { return .defaultCircle }
        default:
            return .defaultCircle
        }
    }
}

#Preview {
    StepProgressView(totalSteps: 4, currentStep: 1)
}
