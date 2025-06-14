//
//  ExerciseView.swift
//  Pushy
//
//  Created by Mutakin on 13/06/25.
//

import SwiftUI

struct ExerciseView: View {
    @Binding var isPresented: Bool
    let configuration: ExerciseConfiguration
    @State private var countdown: Int? = nil
    @State private var isCountingDown = false
    @State private var isExerciseActive = false
    @State private var currentSet: Int = 0
    @State private var repetitionCount: Int = 0
    @State private var repTimer: Timer? = nil
    @State private var isSessionCompleted: Bool = false
    @State private var isResting = false
    @State private var restTimeRemaining: Int = 0
    @State private var restTimer: Timer? = nil

    private var currentSetIndex: Int {
        currentSet - 1
    }
    
    private var isLastSet: Bool {
        currentSet >= configuration.sets.count
    }
    
    private var currentSetConfig: ExerciseSet? {
        guard currentSetIndex >= 0, currentSetIndex < configuration.sets.count else {
            return nil
        }
        return configuration.sets[currentSetIndex]
    }

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
                RepetitionCounterView(value: repetitionCount)
                    .padding(.top, 70)
            }

            GeometryReader { geo in
                ZStack {
                    if countdown == nil && !isExerciseActive && !isSessionCompleted {
                        PositionGuideView(geo: geo)
                    }
                    
                    if !isSessionCompleted {
                        if isResting {
                            VStack(spacing: 16) {
                                Text("Rest Time")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("\(restTimeRemaining)s")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let currentConfig = currentSetConfig {
                            GoalsInfoDisplay(
                                currentSet: currentSet,
                                totalSets: configuration.sets.count,
                                totalReps: currentConfig.reps,
                                weight: currentConfig.weight
                            )
                        }
                    }
                    
                    if let count = countdown {
                        CountdownDisplay(count: count, isCountingDown: isCountingDown)
                    }
                    
                    if isSessionCompleted {
                        SessionCompletedView(
                            totalSets: configuration.sets.count,
                            totalReps: configuration.sets.reduce(0) { $0 + $1.reps },
                            dismissAction: { self.isPresented = false }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                if !isLastSet {
                    isExerciseActive = true
                    currentSet += 1
                    startRepetitionCounter()
                }
            }
        }
        .onChange(of: repetitionCount) { _, newValue in
            guard let currentConfig = currentSetConfig else { return }
            
            if newValue >= currentConfig.reps {
                stopRepetitionCounter()
                if isLastSet {
                    isExerciseActive = false
                    isSessionCompleted = true
                } else {
                    startRestTimer()
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
        guard let currentConfig = currentSetConfig else { return }
        
        repTimer?.invalidate()
        repTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if repetitionCount < currentConfig.reps {
                repetitionCount += 1
            } else {
                repTimer?.invalidate()
            }
        }
    }
    
    func startRestTimer() {
        guard let currentConfig = currentSetConfig else { return }
        
        isResting = true
        restTimeRemaining = currentConfig.restTime
        
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if restTimeRemaining > 0 {
                restTimeRemaining -= 1
            } else {
                timer.invalidate()
                isResting = false
                repetitionCount = 0
                startCountdown()
            }
        }
    }
    
    func stopRepetitionCounter() {
        repTimer?.invalidate()
        repTimer = nil
    }
    
    func resetExercise() {
        repTimer?.invalidate()
        repTimer = nil
        restTimer?.invalidate()
        restTimer = nil
        isExerciseActive = false
        isSessionCompleted = false
        isResting = false
        countdown = nil
        repetitionCount = 0
        currentSet = 0
    }
}

#Preview {
    ExerciseView(
        isPresented: .constant(true),
        configuration: ExerciseConfiguration(
            exerciseName: "Bicep Curl",
            sets: [
                ExerciseSet(weight: 15.0, reps: 5, restTime: 60),
                ExerciseSet(weight: 17.5, reps: 5, restTime: 90),
                ExerciseSet(weight: 20.0, reps: 5, restTime: 120)
            ]
        )
    )
}
