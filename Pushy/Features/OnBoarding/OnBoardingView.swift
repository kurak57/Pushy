//
//  OnBoardingView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = 0

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                        .padding()
                }
                .frame(width: 44)

                Spacer()

                StepProgressView(steps: onboardingModel.count, currentStep: currentIndex)
                    .frame(width: 200)
                
                Spacer()
                
                // Add an empty view with the same width as the back button for balance
                Color.clear
                    .frame(width: 44)
            }
            .padding(.top, 16)

            Spacer()
            
            // Onboarding TabView
            TabView(selection: $currentIndex) {
                ForEach(Array(onboardingModel.enumerated()), id: \.offset) { index, step in
                    VStack(spacing: 20) {
                        Text(step.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Image(step.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 200, maxHeight: 200)

                        Text(step.description)
                            .font(.body)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        if let subtext = step.subtext {
                            Text(subtext)
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            Spacer()

            HStack {
                if currentIndex > 0 {
                    // Back Button
                    Button(action: {
                        currentIndex -= 1
                    }) {
                        Text("Back")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.clear)
                            .foregroundColor(Color.purple)
                            .cornerRadius(10)
                            .padding(.leading)
                    }
                }

                // Next Button
                Button(action: {
                    if currentIndex < onboardingModel.count - 1 {
                        currentIndex += 1
                    }
                }) {
                    Text("Next")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding(currentIndex == 0 ? .horizontal : .trailing)
                }
            }
            .padding(.bottom)

        }
        .background(Color.black.ignoresSafeArea())
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OnboardingView()
        }
    }
}
