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
    @State private var currentRep: Int = 0
    @State private var totalReps: Int = 5
    @State private var repetitionCount: Int = 0
    @State private var repTimer: Timer? = nil
    @State private var isSessionCompleted: Bool = false
    //    @StateObject private var viewModel = ExerciseViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            //            if let image = viewModel.renderedImage {
            //                Image(uiImage: image)
            //                    .resizable()
            //                    .scaledToFit()
            //                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            //                    .background(Color.black)
            //            } else {
            //                Color.black
            //                    .overlay(Text("Starting Camera...").foregroundColor(.white))
            //            }

            //            VStack(spacing: 4) {
            //                Text(viewModel.actionLabel)
            //                    .font(.title)
            //                    .bold()
            //                    .foregroundColor(.white)
            //                Text(viewModel.confidenceLabel)
            //                    .font(.subheadline)
            //                    .foregroundColor(.gray)
            //            }
            //            .padding()
            //            .background(Color.black.opacity(0.6))
            //            .cornerRadius(12)

            // Add gradient overlay
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

            HStack {
                Button(action: {
                    self.isPresented.toggle()
                }) {
                    Image(systemName: "multiply")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: {
                }) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // Repetition Counter Display
            if isExerciseActive && !isSessionCompleted {
                VStack(spacing: 4) {
                    Text("Repetition")
                        .font(.headline)
                        .bold()
                    Text("\(repetitionCount)")
                        .font(.largeTitle)
                        .bold()
                        .id(repetitionCount)
                        .contentTransition(.numericText(value: Double(repetitionCount)))
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)
                .padding(.top, 70) // Adjust based on top buttons
            }

            GeometryReader { geo in
                ZStack {
                    VStack {
                        Spacer()
                        if countdown == nil && !isExerciseActive && !isSessionCompleted {
                            Image("PositionGuide")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.8)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color.green,
                                            lineWidth: 3
                                        )
                                )
                        }
                    }
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .center, vertical: .bottom))
                    
                    // Goals, Set, and Repetition Display
                    if !isSessionCompleted {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Goals")
                                .font(.headline)
                                .bold()
                            Text("Set : \(currentSet)/\(totalSets)")
                                .font(.subheadline)
                            Text("Rep : \(totalReps)")
                                .font(.subheadline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                    }
                    
                    if let count = countdown {
                        Text(count == 0 ? "GO!" : "\(count)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.black)
                            .scaleEffect(isCountingDown ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCountingDown)
                    }
                    
                    VStack {
                        Spacer()
                        if isExerciseActive && !isSessionCompleted {
                            Button(action: {
                                finishExercise()
                            }) {
                                Text("Finish Exercise")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 50)
                        }
                    }
                    
                    if isSessionCompleted {
                        VStack(spacing: 20) {
                            Text("Session completed")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(Color.green)
                            Text("Goals")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("\(totalSets) sets of \(totalReps) repetitions")
                                .font(.title2)
                                .foregroundColor(.white)
                            Button(action: {
                                self.isPresented = false // Dismiss the exercise view
                            }) {
                                Text("Done")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.8))
                        .ignoresSafeArea()
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
                // When countdown reaches zero, start the exercise if not all sets are completed
                if currentSet < totalSets {
                    isExerciseActive = true
                    currentSet += 1 // Increment set as soon as the countdown finishes for the first set
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
                stopRepetitionCounter() // Stop current rep counting
                // Check if all sets are completed
                if currentSet >= totalSets {
                    isExerciseActive = false
                    isSessionCompleted = true
                } else {
                    // Prepare for next set after a break
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        repetitionCount = 0
                        currentSet += 1
                        startRepetitionCounter()
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
        repTimer?.invalidate() // Invalidate any existing timer first
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
        // repetitionCount = 0 // Will be reset in onChange of repetitionCount when set is complete
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
}

#Preview {
    ExerciseView(isPresented: .constant(true))
}
