import Foundation
import Vision
import Combine
import UIKit
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

            
            if viewModel.isExerciseActive && !viewModel.isSessionCompleted {
                TopControlButtons(isPresented: $isPresented, resetAction: viewModel.resetExercise)
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
            viewModel.startCamera()
        }
        .onChange(of: viewModel.countdown) { _, _ in
            viewModel.handleCountdownChange()
        }
        .onChange(of: viewModel.repCount) { _, _ in
            viewModel.handleRepetitionChange()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
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
                
            ],
            restTime: 60
        )
    )
}
