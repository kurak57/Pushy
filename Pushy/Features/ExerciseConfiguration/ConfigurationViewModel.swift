import SwiftUI

@MainActor
public class ConfigurationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var configuration: ExerciseConfiguration
    
    // MARK: - Initialization
    init() {
        self.configuration = ExerciseConfiguration(
            exerciseName: "Bicep Curl",
            sets: [ExerciseSet(weight: 15.0, reps: 5)],
            restTime: 0
        )
    }
    
    // MARK: - Public Methods
    func addSet() {
        configuration.sets.append(ExerciseSet(weight: 15.0, reps: 5))
    }
    
    func updateExerciseName(_ name: String) {
        configuration.exerciseName = name
    }
    
    func updateSet(at index: Int, weight: Double, reps: Int) {
        guard index < configuration.sets.count else { return }
        configuration.sets[index] = ExerciseSet(
            weight: weight,
            reps: reps
        )
    }
    
    func removeSet(at index: Int) {
        // Don't remove if it's the last set
        guard configuration.sets.count > 1, configuration.sets.indices.contains(index) else { return }
        configuration.sets.remove(at: index)
    }
    
    // MARK: - Validation
    func validateConfiguration() -> Bool {
        guard !configuration.sets.isEmpty else { return false }
        
        // Validate each set
        for set in configuration.sets {
            guard set.weight > 0,
                  set.reps > 0
                  /*configuration.restTime > 0*/ else {
                return false
            }
        }
        
        return true
    }
} 
