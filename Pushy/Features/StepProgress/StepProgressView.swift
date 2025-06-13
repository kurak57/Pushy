//
//  StepProgressView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct StepProgressView: View {
    let steps: Int
    let currentStep: Int

    var body: some View {
        ZStack(alignment: .leading) {
            // Background bar
            Capsule()
                .fill(Color.purple.opacity(0.3))
                .frame(height: 12)

            // Fill bar
            GeometryReader { geometry in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: (geometry.size.width / CGFloat(steps)) * CGFloat(currentStep + 1), height: 12)
            }
        }
        .frame(height: 12)
        .overlay(
            HStack(spacing: 0) {
                ForEach(0..<steps, id: \.self) { index in
                    ZStack {
                        Circle()
                            .fill(index <= currentStep ? Color.pink.opacity(0.9) : Color.purple.opacity(0.5))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(index == currentStep ? 0.9 : 0), lineWidth: 2)
                            )

                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                    if index != steps - 1 {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 4)
        )
        .frame(height: 32)
    }
}

#Preview {
    StepProgressView(steps: 5, currentStep: 2)
}
