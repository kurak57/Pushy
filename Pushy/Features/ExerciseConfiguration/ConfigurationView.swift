//
//  ConfigurationView.swift
//  Pushy
//
//  Created by Mutakin on 14/06/25.
//


import SwiftUI

struct ExerciseSet {
    var weight: Double
    var reps: Int
    var restTime: Int // in seconds
}

struct ExerciseConfiguration {
    var exerciseName: String
    var sets: [ExerciseSet]
    var isRestTimerEnabled: Bool
}

struct ConfigurationView: View {
    let onStartWorkout: (ExerciseConfiguration) -> Void
    @StateObject private var viewModel = ConfigurationViewModel()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case weight, reps, rest
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack() {
                    // Title
                    Text(viewModel.configuration.exerciseName)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                    
                    // Video preview box
                    VStack {
                        Image(systemName: "photo") // placeholder
                            .resizable()
                            .scaledToFit()
                            .frame(width: 145, height: 145)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)
                        
                        Text("Video tutorial")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    
                    // Notes field
                    HStack {
                        Text("Add routine notes here")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    
                    // Rest Timer Toggle
                    HStack {
                        Image(systemName: "alarm")
                            .foregroundColor(.cyan)
                        Text("Rest Timer:")
                            .foregroundColor(.cyan)
                        
                        Toggle("", isOn: Binding(
                            get: { viewModel.configuration.isRestTimerEnabled },
                            set: { _ in viewModel.toggleRestTimer() }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .cyan))
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 8)
                    .font(.system(size: 17, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Set/Weight/Reps/Rest Headers
                    VStack {
                        HStack {
                            Text("SET")
                            Spacer()
                            Text("KG")
                            Spacer()
                            Text("REPS")
                            Spacer()
                            if viewModel.configuration.isRestTimerEnabled {
                                Text("REST")
                                Spacer()
                            }
                        }
                        .font(.system(size: 17, weight: .bold, design: .default))
                        .foregroundColor(.gray)
                        .padding(.bottom, 16)
                        
                        // Sets List
                        ForEach(Array(viewModel.configuration.sets.enumerated()), id: \.offset) { index, set in
                            HStack(alignment: .center, spacing: 24) {
                                Text("\(index + 1)")
                                    .foregroundColor(.white)
                                Spacer()
                                TextField("Weight", value: Binding(
                                    get: { viewModel.configuration.sets[index].weight },
                                    set: { newValue in
                                        viewModel.updateSet(
                                            at: index,
                                            weight: newValue,
                                            reps: viewModel.configuration.sets[index].reps,
                                            restTime: viewModel.configuration.sets[index].restTime
                                        )
                                    }
                                ), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .weight)
                                Spacer()
                                TextField("Reps", value: Binding(
                                    get: { viewModel.configuration.sets[index].reps },
                                    set: { newValue in
                                        viewModel.updateSet(
                                            at: index,
                                            weight: viewModel.configuration.sets[index].weight,
                                            reps: newValue,
                                            restTime: viewModel.configuration.sets[index].restTime
                                        )
                                    }
                                ), format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .focused($focusedField, equals: .reps)
                                if viewModel.configuration.isRestTimerEnabled {
                                    Spacer()
                                    TextField("Rest", value: Binding(
                                        get: { viewModel.configuration.sets[index].restTime },
                                        set: { newValue in
                                            viewModel.updateSet(
                                                at: index,
                                                weight: viewModel.configuration.sets[index].weight,
                                                reps: viewModel.configuration.sets[index].reps,
                                                restTime: newValue
                                            )
                                        }
                                    ), format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .frame(width: 60)
                                    .focused($focusedField, equals: .rest)
                                    Spacer()
                                }
                            }
                            .font(.system(size: 20, weight: .semibold, design: .default))
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    
                    // Add set button
                    Button(action: viewModel.addSet) {
                        HStack {
                            Image(systemName: "plus")
                                .bold()
                            Text("Add Set")
                                .font(.system(size: 20, weight: .bold, design: .default))
                        }
                    }
                    .padding(.vertical, 12)
                    
                    // Add padding at the bottom to account for the fixed button
                    Spacer()
                        .frame(height: 100)
                }
                .padding(.horizontal, 16)
            }
            
            // Fixed bottom button
            VStack {
                Button(action: {
                    if viewModel.validateConfiguration() {
                        onStartWorkout(viewModel.configuration)
                    }
                }) {
                    Text("Start Workout")
                        .foregroundColor(.black)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color.leftGradient, location: 0.00),
                                    Gradient.Stop(color: Color.rightGradient, location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0, y: 0.5),
                                endPoint: UnitPoint(x: 1, y: 0.5)
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }
}
