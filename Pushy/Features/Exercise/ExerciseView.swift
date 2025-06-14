//
//  ExerciseView.swift
//  Pushy
//
//  Created by Mutakin on 13/06/25.
//

import SwiftUI

struct ExerciseView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel: ExerciseViewModel
    
    init(isPresented: Binding<Bool>, configuration: ExerciseConfiguration) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: ExerciseViewModel(configuration: configuration))
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

            TopControlButtons(isPresented: $isPresented, resetAction: viewModel.resetExercise)
            
            if viewModel.isExerciseActive && !viewModel.isSessionCompleted {
                RepetitionCounterView(value: viewModel.repetitionCount)
                    .padding(.top, 70)
            }

            GeometryReader { geo in
                ZStack {
                    if viewModel.countdown == nil && !viewModel.isExerciseActive && !viewModel.isSessionCompleted {
                        PositionGuideView(geo: geo)
                    }
                    
                    if !viewModel.isSessionCompleted {
                        if viewModel.isResting {
                            VStack(spacing: 16) {
                                Text("Rest Time")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Text("\(viewModel.restTimeRemaining)s")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.cyan)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if let setInfo = viewModel.currentSetInfo {
                            GoalsInfoDisplay(
                                currentSet: setInfo.currentSet,
                                totalSets: setInfo.totalSets,
                                totalReps: setInfo.reps,
                                weight: setInfo.weight
                            )
                        }
                    }
                    
                    if let count = viewModel.countdown {
                        CountdownDisplay(count: count, isCountingDown: viewModel.isCountingDown)
                    }
                    
                    if viewModel.isSessionCompleted {
                        SessionCompletedView(
                            totalSets: viewModel.currentSetInfo?.totalSets ?? 0,
                            totalReps: viewModel.totalReps,
                            dismissAction: { self.isPresented = false }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            viewModel.startExercise()
        }
        .onChange(of: viewModel.countdown) { _, _ in
            viewModel.handleCountdownChange()
        }
        .onChange(of: viewModel.repetitionCount) { _, _ in
            viewModel.handleRepetitionChange()
        }
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
