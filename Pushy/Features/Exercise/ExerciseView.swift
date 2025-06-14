//
//  ExerciseView.swift
//  Pushy
//
//  Created by Mutakin on 13/06/25.
//

import SwiftUI

struct ExerciseView: View {
    @Binding var isPresented: Bool
    @State private var countdown: Int? = nil
    @State private var isCountingDown = false
    @State private var isExerciseActive = false
    @State private var currentSet: Int = 0
    @State private var totalSets: Int = 3
    @State private var totalReps: Int = 5
    @State private var repetitionCount: Int = 0
    @State private var repTimer: Timer? = nil
    @State private var isSessionCompleted: Bool = false
    @State private var exerciseWeight: Double = 15.0
    //    @StateObject private var viewModel = ExerciseViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.3),
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            TopControlButtons(isPresented: $isPresented, resetAction: resetExercise)
            
            if isExerciseActive && !isSessionCompleted {
                RepetitionCounterDisplay(repetitionCount: repetitionCount)
            }

            GeometryReader { geo in
                ZStack {
                    if countdown == nil && !isExerciseActive && !isSessionCompleted {
                        PositionGuideView(geo: geo)
                    }
                    
                    if !isSessionCompleted {
                        GoalsInfoDisplay(currentSet: currentSet, totalSets: totalSets, totalReps: totalReps, weight: exerciseWeight)
                    }
                    
                    if let count = countdown {
                        CountdownDisplay(count: count, isCountingDown: isCountingDown)
                    }
                    
                    if isSessionCompleted {
                        SessionCompletedView(
                            totalSets: totalSets,
                            totalReps: totalReps,
                            dismissAction: { self.isPresented = false }
                        )
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                startCountdown()
            }
        }
        .onChange(of: countdown) { _, newValue in
            if newValue != nil {
                withAnimation {
                    isCountingDown = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        isCountingDown = false
                    }
                }
            } else {
                if currentSet < totalSets {
                    isExerciseActive = true
                    currentSet += 1
                    startRepetitionCounter()
                }
            }
        }
        .onChange(of: isExerciseActive) { _, newValue in
            if newValue && !isSessionCompleted {
                // Do nothing here, startRepetitionCounter is called after countdown finishes for each set
            } else {
                stopRepetitionCounter()
            }
        }
        .onChange(of: repetitionCount) { _, newValue in
            if newValue >= totalReps {
                stopRepetitionCounter()
                if currentSet >= totalSets {
                    isExerciseActive = false
                    isSessionCompleted = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        repetitionCount = 0
                        startCountdown()
                    }
                }
            }
        }
    }
    
    func startCountdown() {
        countdown = 3
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if let currentCount = countdown {
                if currentCount > 0 {
                    countdown = currentCount - 1
                } else {
                    timer.invalidate()
                    countdown = nil
                }
            }
        }
    }
    
    func startRepetitionCounter() {
        repTimer?.invalidate()
        repTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if repetitionCount < totalReps {
                repetitionCount += 1
            } else {
                repTimer?.invalidate()
            }
        }
    }
    
    func stopRepetitionCounter() {
        repTimer?.invalidate()
        repTimer = nil
    }
    
    func finishExercise() {
        repTimer?.invalidate()
        repTimer = nil
        isExerciseActive = false
        isSessionCompleted = false
        countdown = nil
        repetitionCount = 0
        currentSet = 0
    }
    
    func resetExercise() {
        repTimer?.invalidate()
        repTimer = nil
        isExerciseActive = false
        isSessionCompleted = false
        countdown = nil
        repetitionCount = 0
        currentSet = 0
        // Optionally, reset other exercise-specific states here if needed
    }
}

#Preview {
    ExerciseView(isPresented: .constant(true))
}
