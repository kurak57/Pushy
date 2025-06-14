//
//  SwiftUIView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct HomeView: View {
    @State private var showOnboarding = false
    @State private var startExercise: Bool = false
    
    var body: some View {
        NavigationStack {
            ConfigurationView(onStartWorkout: {
                showOnboarding = true
            })
            .navigationDestination(isPresented: $showOnboarding) {
                OnboardingView(showOnboarding: $showOnboarding, startExercise: $startExercise)
            }
            .navigationDestination(isPresented: $startExercise) {
                ExerciseView()
                    .navigationBarBackButtonHidden(true)
            }
          
        }
        
    }
}

#Preview {
    HomeView()
}

