//
//  ConfigurationView.swift
//  Pushy
//
//  Created by Mutakin on 14/06/25.
//

import SwiftUI
import AVKit

struct ExerciseSet {
    var weight: Double
    var reps: Int
}

struct ExerciseConfiguration {
    var exerciseName: String
    var sets: [ExerciseSet]
    var restTime: Int // in seconds
}

struct ConfigurationView: View {
    let onStartWorkout: (ExerciseConfiguration) -> Void
    @StateObject private var viewModel = ConfigurationViewModel()
    @FocusState private var focusedField: Field?
    @State private var showRestTimePicker = false
    
    enum Field {
        case weight, reps, rest
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack {
                    titleSection
                    VideoPlayerView(videoName: "bicep-curl-video", fileExtension: "mp4")
                    restTimeSection
                    setsSection
                    addSetButton
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, 16)
            }
            startWorkoutButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(
            stops: [
                Gradient.Stop(color: .bgPurple40, location: 0.00),
                Gradient.Stop(color: .black, location: 0.20),
                Gradient.Stop(color: .black, location: 1.00)
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
        ))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
    
    private var titleSection: some View {
        Text(viewModel.configuration.exerciseName)
            .font(.title)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding()
    }
    
    private var restTimeSection: some View {
        HStack {
            Image(systemName: "alarm")
                .foregroundColor(.highlightPurple)
            Text("Rest Timer:")
                .foregroundColor(.highlightPurple)
            
            Spacer()
            
            Button {
                showRestTimePicker = true
            } label: {
                HStack(spacing: 4) {
                    Text(viewModel.configuration.restTime == 0 ? "OFF" : "\(viewModel.configuration.restTime)s")
                        .foregroundColor(.highlightPurple)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.highlightPurple)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .sheet(isPresented: $showRestTimePicker) {
                VStack(spacing: 0) {
                    // Handle (grabber)
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    
                    // Title
                    Text("Rest Timer")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.highlightPurple)
                        .padding(.bottom, 12)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal)

                    // Picker
                    Picker("Rest Time", selection: Binding(
                        get: { viewModel.configuration.restTime },
                        set: { newValue in viewModel.configuration.restTime = newValue }
                    )) {
                        ForEach(Array(stride(from: 0, through: 60, by: 5)), id: \.self) { second in
                            if second == 0 {
                                Text("OFF").tag(0)
                            } else {
                                Text("\(second)s").tag(second)
                            }
                        }
                        .foregroundColor(Color.highlightPurple)
                        .fontWeight(.bold)
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 150)
                    .clipped()
                    .padding(.top, 4)
                    .accentColor(.highlightPurple)
                    
                    Spacer()
                    
                    // Done Button
                    Button(action: {
                        showRestTimePicker = false
                    }) {
                        Text("Done")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                            .shadow(color: .gray, radius: 0, x: 0, y: 4)
                        
                    }
                }
                .background(Color.sheet.ignoresSafeArea())
                .presentationDetents([.fraction(0.4)])
            }
        }
        .padding(.vertical, 12)
        .font(.system(size: 17, weight: .bold, design: .default))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var setsSection: some View {
        VStack {
            HStack(alignment: .center, spacing: 24) {
                Text("SET")
                Spacer()
                Text("KG")
                Spacer()
                Text("REPS")
                Spacer()
                Text("")
                Spacer()
            }
            .font(.system(size: 17, weight: .bold, design: .default))
            .foregroundColor(.gray)
            .padding(.bottom, 16)
            // .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(Array(viewModel.configuration.sets.enumerated()), id: \.offset) { index, set in
                setRow(index: index, set: set)
            }
        }
    }
    
    private func setRow(index: Int, set: ExerciseSet) -> some View {
        HStack(alignment: .center, spacing: 24) {
            Text("\(index + 1)")
                .foregroundColor(.white)
            Spacer()
            
            TextField("Weight", value: Binding(
                get: {
                    if viewModel.configuration.sets.indices.contains(index) {
                        return viewModel.configuration.sets[index].weight
                    } else {
                        return 0 // fallback agar tidak crash
                    }
                },
                set: { newValue in
                    if viewModel.configuration.sets.indices.contains(index) {
                        viewModel.updateSet(
                            at: index,
                            weight: newValue,
                            reps: viewModel.configuration.sets[index].reps
                        )
                    }
                }
            ), format: .number)
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .focused($focusedField, equals: .weight)
            
            Spacer()
            
            TextField("Reps", value: Binding(
                get: {
                    if viewModel.configuration.sets.indices.contains(index) {
                        return viewModel.configuration.sets[index].reps
                    } else {
                        return 0 // fallback agar tidak crash
                    }
                },
                set: { newValue in
                    if viewModel.configuration.sets.indices.contains(index) {
                        viewModel.updateSet(
                            at: index,
                            weight: viewModel.configuration.sets[index].weight,
                            reps: newValue
                        )
                    }
                }
            ), format: .number)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .focused($focusedField, equals: .reps)
            
            Spacer()
            
            Button {
                viewModel.removeSet(at: index)
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.gray.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .font(.system(size: 20, weight: .semibold, design: .default))
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private var addSetButton: some View {
        Button(action: viewModel.addSet) {
            HStack {
                Image(systemName: "plus")
                    .bold()
                Text("Add Set")
                    .font(.system(size: 20, weight: .bold, design: .default))
            }
        }
        .padding(.vertical, 12)
    }
    
    private var startWorkoutButton: some View {
        VStack {
            Button {
                if viewModel.validateConfiguration() {
                    onStartWorkout(viewModel.configuration)
                }
            } label: {
                Text("Start Workout")
                    .foregroundColor(.black)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        .white
                    )
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .shadow(color: .gray, radius: 0, x: 0, y: 4)
            .shadow(color: .gray, radius: 0, x: 0, y: 4)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0),
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .allowsHitTesting(false)
        )
    }
}

#Preview {
    HomeView()
}
