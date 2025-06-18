import Foundation
import Vision
import Combine
import UIKit
import SwiftUI

struct ExerciseView: View {
    @Binding var isPresented: Bool
    @State private var isNoPersonDetected: Bool = false
    @StateObject private var viewModel: ExerciseViewModel
    
    init(isPresented: Binding<Bool>, configuration: ExerciseConfiguration) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: ExerciseViewModel(configuration: configuration))
    }
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Camera Preview Layer
                CameraPreviewView(viewModel: viewModel)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                // "No Person" Overlay
                if isNoPersonDetected && !viewModel.isResting{
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                }
                // UI Elements Layer
                VStack {
                    TopControlButtons(
                        isPresented: $isPresented,
                        resetAction: viewModel.resetExercise,
                        isExerciseActive: viewModel.isExerciseActive,
                        isSessionCompleted: viewModel.isSessionCompleted,
                        repetitionCount: viewModel.repCount
                    )
                    .safeAreaPadding(.top)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black, Color.black.opacity(0.2)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    if viewModel.isExerciseActive &&
                       !viewModel.isSessionCompleted &&
                       !viewModel.isResting &&
                       (viewModel.actionLabel == "Loose Back" || viewModel.actionLabel == "Elevated Elbow") {

                        Text(viewModel.actionLabel)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(12)
                    }


                    Spacer()
                }

                
                // Position Guide and Feedback Layer
                if viewModel.countdown == nil && !viewModel.isExerciseActive && !viewModel.isSessionCompleted {
                    PositionGuideView(geo: geo, isPositionCorrect: viewModel.isInCorrectPosition)
                    
                    PositionFeedbackView(
                        feedback: viewModel.positionFeedback,
                        isInCorrectPosition: viewModel.isInCorrectPosition
                    )
                    .transition(.opacity)
                    
                }
                
                // Exercise State Layer
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
                        .safeAreaPadding(.bottom)
                    }
                }

                // Countdown Layer
                if let count = viewModel.countdown {
                    CountdownDisplay(count: count, isCountingDown: viewModel.isCountingDown)
                }
                // Session Completed Layer
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
        .ignoresSafeArea()
        .onAppear {
            viewModel.startCamera()
        }
        .onChange(of: viewModel.countdown) { _, _ in
            
            viewModel.handleCountdownChange()
        }
        .onChange(of: viewModel.repCount) { _, _ in
            viewModel.handleRepetitionChange()
        }
        .onChange(of: viewModel.actionLabel) { _, newValue in
            if newValue == "No Person" {
                isNoPersonDetected = true
            } else if isNoPersonDetected {
                isNoPersonDetected = false
            }
        }
        .onDisappear {
            viewModel.stopCamera()
            viewModel.cleanup()
        }
        
    }
}

struct CameraPreviewView: View {
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        ZStack {
            if let image = viewModel.renderedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped(antialiased: true)
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
