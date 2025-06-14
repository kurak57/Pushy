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
            ExerciseSet(weight: 15.0, reps: 5, restTime: 60),
            ExerciseSet(weight: 17.5, reps: 5, restTime: 90),
            ExerciseSet(weight: 20.0, reps: 5, restTime: 120)
        ]
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

