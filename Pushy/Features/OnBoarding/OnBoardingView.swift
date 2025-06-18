//
//  OnBoardingView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @Binding var startExercise: Bool
    @State private var currentIndex = 0
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Button {
                        showOnboarding = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    .padding(.bottom, 8)
                    
                    Spacer()
                }
                
                StepComponent(totalSteps: onboardingModel.count, currentStep: currentIndex)
                    .frame(width: 200)
            }
            .padding(.top, 16)
            
            // Onboarding TabView
            TabView(selection: $currentIndex) {
                ForEach(Array(onboardingModel.enumerated()), id: \.offset) { index, step in
                    VStack(spacing: 32) {
                        Text(step.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 36)
                        
                        Image(step.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 256)
                        
                        VStack (spacing: 24) {
                            Text(step.description)
                                .font(.system(size: 17))
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .frame(width: 340, alignment: .top)
                            if let subtext = step.subtext {
                                Text(subtext)
                                    .font(.system(size: 17))
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.gray)
                                    .frame(width: 320, alignment: .top)
                            }
                        }
                        Spacer()
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            HStack {
                if currentIndex < onboardingModel.count - 1 {
                    // Skip Button
                    Button(action: {
                        startExercise = true
                    }) {
                        Text("Skip")
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
                    } else {
                        startExercise = true
                    }
                }) {
                    Text(currentIndex == onboardingModel.count - 1 ? "Get Started" : "Next")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding(currentIndex == 0 ? .trailing : .horizontal)
                }
                //                .padding(.horizontal, 16)
                //                .padding(.bottom, 24)
                .shadow(color: .gray, radius: 0, x: 0, y: 4)
                .shadow(color: .gray, radius: 0, x: 0, y: 4)
            }
            .padding(.bottom)
            
        }
        .background(Color.black.ignoresSafeArea())
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(showOnboarding: .constant(true), startExercise: .constant(false))
    }
}
