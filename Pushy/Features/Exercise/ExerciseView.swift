import Foundation
import Vision
import Combine
import UIKit
import SwiftUI

struct ExerciseView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel: ExerciseViewModelUIOnly
    
    init(isPresented: Binding<Bool>, configuration: ExerciseConfiguration) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: ExerciseViewModelUIOnly(configuration: configuration))
    }
    
    @State private var countdown: Int? = nil
    @State private var isCountingDown = false
    @State private var isExerciseActive = false
    @State private var currentSet: Int = 0
    @State private var totalSets: Int = 3
    @State private var totalReps: Int = 5
    @State private var isSessionCompleted: Bool = false
    @State private var exerciseWeight: Double = 15.0
    @StateObject private var viewModel = ExerciseViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            CameraPreviewView(viewModel: viewModel)
                .ignoresSafeArea()

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
            TopControlButtons(isPresented: $isPresented, resetAction: resetExercise)

            if isExerciseActive && !isSessionCompleted {
                RepetitionCounterDisplay(
                    repetitionCount: viewModel.repCount,
                    actionLabel: viewModel.actionLabel,
                    confidenceLabel: viewModel.confidenceLabel
                )
                .padding(.bottom, 200)
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
            viewModel.startCamera()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                startCountdown()
            }
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .onChange(of: countdown) { _, newValue in
            if newValue != nil {
                withAnimation { isCountingDown = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation { isCountingDown = false }
                }
            } else {
                if currentSet < totalSets {
                    isExerciseActive = true
                    currentSet += 1
                    // ViewModel repCount will start incrementing automatically
                }
            }
        }
        .onChange(of: isExerciseActive) { _, newValue in
            if newValue && !isSessionCompleted {
                // Reset VM counter for new set
                viewModel.resetRepCount()
            }
        }
        .onChange(of: viewModel.repCount) { _, newValue in
            if newValue >= totalReps {
                isExerciseActive = false
                if currentSet >= totalSets {
                    isSessionCompleted = true
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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

    func finishExercise() {
        isExerciseActive = false
        isSessionCompleted = false
        countdown = nil
        currentSet = 0
        viewModel.resetRepCount()
    }

    func resetExercise() {
        isExerciseActive = false
        isSessionCompleted = false
        countdown = nil
        currentSet = 0
        viewModel.resetRepCount()
    }
}

struct CameraPreviewView: View {
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        ZStack {
            Color.black
            if let image = viewModel.renderedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
            } else {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Loading Camera...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
            }
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
            ],
            isRestTimerEnabled: true
        )
    )
}
