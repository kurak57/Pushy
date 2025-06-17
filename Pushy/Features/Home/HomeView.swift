//
//  SwiftUIView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct HomeView: View {
    @State private var showOnboarding = false
    @State private var startExercise = false
    @State private var exerciseConfiguration = ExerciseConfiguration(
        exerciseName: "Bicep Curl",
        sets: [
            
        ],
        restTime: 0
    )
    
    var body: some View {
        NavigationStack {
            ConfigurationView { configuration in
                exerciseConfiguration = configuration
                showOnboarding = true
            }
            .navigationDestination(isPresented: $showOnboarding) {
                OnboardingView(
                    showOnboarding: $showOnboarding,
                    startExercise: $startExercise
                )
                .navigationBarBackButtonHidden(true)
                .navigationDestination(isPresented: $startExercise) {
                    ExerciseView(
                        isPresented: $startExercise,
                        configuration: exerciseConfiguration
                    )
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}

