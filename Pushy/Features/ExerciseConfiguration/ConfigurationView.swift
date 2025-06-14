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
}

struct ConfigurationView: View {
    let onStartWorkout: (ExerciseConfiguration) -> Void
    @State private var configuration = ExerciseConfiguration(
        exerciseName: "Bicep Curl",
        sets: [ExerciseSet(weight: 15.0, reps: 5, restTime: 60)]
    )
    @State private var isRestTimerEnabled = true
    
    var body: some View {
        VStack() {
            // Title
            Text(configuration.exerciseName)
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
                
                Toggle("", isOn: $isRestTimerEnabled)
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
                    if isRestTimerEnabled {
                        Text("REST")
                        Spacer()
                    }
                }
                .font(.system(size: 17, weight: .bold, design: .default))
                .foregroundColor(.gray)
                .padding(.bottom, 16)
                
                // Sets List
                ForEach(Array(configuration.sets.enumerated()), id: \.offset) { index, set in
                    HStack(alignment: .center, spacing: 24) {
                        Text("\(index + 1)")
                            .foregroundColor(.white)
                        Spacer()
                        TextField("Weight", value: $configuration.sets[index].weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        Spacer()
                        TextField("Reps", value: $configuration.sets[index].reps, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        if isRestTimerEnabled {
                            Spacer()
                            TextField("Rest", value: $configuration.sets[index].restTime, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .frame(width: 60)
                            Spacer()
                        }
                    }
                    .font(.system(size: 20, weight: .semibold, design: .default))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            // Add set button
            Button(action: {
                configuration.sets.append(ExerciseSet(weight: 15.0, reps: 5, restTime: 60))
            }) {
                HStack {
                    Image(systemName: "plus")
                        .bold()
                    Text("Add Set")
                        .font(.system(size: 20, weight: .bold, design: .default))
                }
            }
            .padding(.vertical, 12)
            
            Spacer()
            
            // Fixed bottom button
            VStack {
                Spacer()
                
                Button(action: { onStartWorkout(configuration) }) {
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
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
