//
//  SwiftUIView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct HomeView: View {
    @State private var showOnboarding = false
    var body: some View {
        ZStack {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
            } else {
                // Main content
                VStack() {
                    // Title
                    Text("Bicep Curl")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                    
                    // Video preview box
                    VStack {
                        Image(systemName: "photo") // placeholder
                            .resizable()
                            .scaledToFit()
                            .frame(width: 145, height: 145)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)
                        
                        Text("Video tutorial")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1) // Rounded border
                    )
                    
                    // Notes field (just a placeholder for now)
                    HStack {
                        Text("Add routine notes here")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    // Rest Timer
                    HStack {
                        Image(systemName: "alarm")
                            .foregroundColor(.cyan)
                        Text("Rest Timer: OFF")
                            .foregroundColor(.cyan)
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 8)
                    .font(.system(size: 17, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Set/Weight/Reps Headers
                    VStack {
                        HStack {
                            Text("SET")
                            Spacer()
                            Text("KG")
                            Spacer()
                            Text("REPS")
                            Spacer()
                        }
                        .font(.system(size: 17, weight: .bold, design: .default))
                        .foregroundColor(.gray)
                        .padding(.bottom, 16)
                        
                        // First set row
                        HStack {
                            
                        }
                        HStack(alignment: .center, spacing: 24) {
                            Text("1")
                                .foregroundColor(.white)
                            Spacer()
                            Text("-")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("-")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment:. center)
                    }
                    
                    // Add set button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus")
                                .bold()
                            Text("Add Set")
                                .font(.system(size: 20, weight: .bold, design: .default))
                        }
                    }
                    .padding(.vertical, 12)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Fixed bottom button
                VStack {
                    Spacer()
                    
                    Button(action: {
                        showOnboarding = true
                    }) {
                        Text("Start Workout")
                            .foregroundColor(.black)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color.leftGradient, location: 0.00),
                                        Gradient.Stop(color: Color.rightGradient, location: 1.00),
                                    ],
                                    startPoint: UnitPoint(x: 0, y: 0.5),
                                    endPoint: UnitPoint(x: 1, y: 0.5)
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    HomeView()
}
