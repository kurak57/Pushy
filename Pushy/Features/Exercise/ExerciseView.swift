import Foundation
import Vision
import Combine
import UIKit
import SwiftUI

struct ExerciseView: View {
    @Binding var isPresented: Bool
    @State private var isNoPersonDetected: Bool = false
    @StateObject private var viewModel: ExerciseViewModel
    @State private var showNiceLabel: Bool = false
    
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
                if isNoPersonDetected && !viewModel.isResting {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                        
                        Text("No Person Found")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                Color.textOverlayBG
                                    .frame(height: nil)
                            )
                            .cornerRadius(0)
                    }
                }
                
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
                // UI Elements Layer
                if !isNoPersonDetected {
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
                            !viewModel.isResting {
                            
                            Group {
                                if showNiceLabel {
                                    Text("Nice")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.green)
                                } else if viewModel.actionLabel == "Loose Back" || viewModel.actionLabel == "Elevated Elbow" {
                                    Text(viewModel.actionLabel)
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(12)
                        }

                        Spacer()
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
                        ZStack {
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()
                            
                            VStack(spacing: 0) {
                                Text("Rest Time")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(.whiteShadow)
                                HStack(alignment: .center, spacing: 10) {
                                    Text("\(viewModel.restTimeRemaining)")
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("s")
                                        .foregroundColor(.whiteShadow)
                                }
                                .font(.system(size: 60))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(
                                Color.textOverlayBG
                                    .frame(height: nil)
                            )
                            .cornerRadius(0)
                        }
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
                    if !isNoPersonDetected {
                        ZStack {
                            // Overlay
                            Color.black.opacity(0.5)
                                .ignoresSafeArea()
                            
                            // Countdown view
                            CountdownDisplay(count: count, isCountingDown: viewModel.isCountingDown)
                        }
                    }
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
            
            if viewModel.actionLabel == "Good Bicep Curl" {
                showNiceLabel = true
                
                // Sembunyikan lagi setelah 1 detik
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation {
                        showNiceLabel = false
                    }
                }
            }
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
