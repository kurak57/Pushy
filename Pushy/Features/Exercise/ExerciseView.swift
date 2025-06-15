import Foundation
import Vision
import Combine
import UIKit
import SwiftUI

struct ExerciseView: View {
    @Binding var isPresented: Bool
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
                    if countdown == nil && !isExerciseActive && !isSessionCompleted {
                        PositionGuideView(geo: geo)
                    }

                    if !isSessionCompleted {
                        GoalsInfoDisplay(
                            currentSet: currentSet,
                            totalSets: totalSets,
                            totalReps: totalReps,
                            weight: exerciseWeight
                        )
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
    ExerciseView(isPresented: .constant(true))
}
