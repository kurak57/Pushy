import SwiftUI

@MainActor
class ExerciseViewModelUIOnly: ObservableObject {
    // MARK: - Published Properties
    @Published var countdown: Int?
    @Published var isCountingDown = false
    @Published var isExerciseActive = false
    @Published var currentSet: Int = 0
    @Published var repetitionCount: Int = 0
    @Published var isSessionCompleted = false
    @Published var isResting = false
    @Published var restTimeRemaining: Int = 0
    
    // MARK: - Private Properties
    private var repTimer: Timer?
    private var restTimer: Timer?
    private let configuration: ExerciseConfiguration
    
    // MARK: - Computed Properties
    private var currentSetIndex: Int {
        currentSet - 1
    }
    
    private var isLastSet: Bool {
        currentSet >= configuration.sets.count
    }
    
    private var currentSetConfig: ExerciseSet? {
        guard currentSetIndex >= 0, currentSetIndex < configuration.sets.count else {
            return nil
        }
        return configuration.sets[currentSetIndex]
    }
    
    // MARK: - Initialization
    init(configuration: ExerciseConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    func startExercise() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startCountdown()
        }
    }
    
    func resetExercise() {
        stopAllTimers()
        isExerciseActive = false
        isSessionCompleted = false
        isResting = false
        countdown = nil
        repetitionCount = 0
        currentSet = 0
        
        // Start the exercise again after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startExercise()
        }
    }
    
    // MARK: - Private Methods
    private func startCountdown() {
        countdown = 3
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if let currentCount = self.countdown {
                if currentCount > 0 {
                    self.countdown = currentCount - 1
                } else {
                    timer.invalidate()
                    self.countdown = nil
                }
            }
        }
    }
    
    private func startRepetitionCounter() {
        guard let currentConfig = currentSetConfig else { return }
        
        repTimer?.invalidate()
        repTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.repetitionCount < currentConfig.reps {
                self.repetitionCount += 1
            } else {
                self.repTimer?.invalidate()
            }
        }
    }
    
    private func startRestTimer() {
        guard let currentConfig = currentSetConfig else { return }
        
        isResting = true
        restTimeRemaining = currentConfig.restTime
        
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.restTimeRemaining > 0 {
                self.restTimeRemaining -= 1
            } else {
                timer.invalidate()
                self.isResting = false
                self.repetitionCount = 0
                self.startCountdown()
            }
        }
    }
    
    private func stopAllTimers() {
        repTimer?.invalidate()
        repTimer = nil
        restTimer?.invalidate()
        restTimer = nil
    }
    
    // MARK: - State Updates
    func handleCountdownChange() {
        if countdown != nil {
            withAnimation {
                isCountingDown = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    self.isCountingDown = false
                }
            }
        } else {
            if !isLastSet {
                isExerciseActive = true
                currentSet += 1
                startRepetitionCounter()
            }
        }
    }
    
    func handleRepetitionChange() {
        guard let currentConfig = currentSetConfig else { return }
        
        if repetitionCount >= currentConfig.reps {
            stopAllTimers()
            if isLastSet {
                isExerciseActive = false
                isSessionCompleted = true
            } else {
                if configuration.isRestTimerEnabled {
                    startRestTimer()
                } else {
                    repetitionCount = 0
                    startCountdown()
                }
            }
        }
    }
    
    // MARK: - View Helpers
    var currentSetInfo: (currentSet: Int, totalSets: Int, reps: Int, weight: Double)? {
        guard let currentConfig = currentSetConfig else { return nil }
        return (currentSet, configuration.sets.count, currentConfig.reps, currentConfig.weight)
    }
    
    var totalReps: Int {
        configuration.sets.reduce(0) { $0 + $1.reps }
    }
} 
