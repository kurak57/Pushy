import Foundation
import Vision
import Combine
import UIKit
import SwiftUI
import AVFoundation

public class ExerciseViewModel: ObservableObject {
    // MARK: - ML State
    @Published var actionLabel: String = "Observing..."
    @Published var confidenceLabel: String = "Observing..."
    @Published var renderedImage: UIImage?
    @Published var repCount: Int = 0
    @Published var currentAngle: Double = 0.0
    @Published var currentArmpitAngle: Double = 0.0
    
    // MARK: - UI State
    @Published var countdown: Int?
    @Published var isCountingDown = false
    @Published var isExerciseActive = false
    @Published var currentSet: Int = 0
    @Published var isSessionCompleted = false
    @Published var isResting = false
    @Published var restTimeRemaining: Int = 0
    @Published var isInCorrectPosition = false
    @Published var positionFeedback = "Position yourself in the guide"
    @Published var formFeedback = ""
    
    // MARK: - Private Properties
    private var videoCapture: VideoCapture?
    private var videoProcessingChain: VideoProcessingChain?
    private var cancellables = Set<AnyCancellable>()
    private var actionFrameCounts = [String: Int]()
    private var restTimer: Timer?
    private let configuration: ExerciseConfiguration
    private let processingQueue = DispatchQueue(label: "com.pushy.processing", qos: .userInitiated)
    private var lastProcessedTime: TimeInterval = 0
    private let minimumProcessingInterval: TimeInterval = 1.0 / 30.0 // 30 FPS limit
    private var correctPositionStartTime: TimeInterval?
    private let requiredPositionHoldTime: TimeInterval = 3.0
    private var wasInCorrectPosition: Bool = false
    private var audioPlayer: AVAudioPlayer?
    private var completionAudioPlayer: AVAudioPlayer?
    
    // MARK: - Per‑arm rep‑counting state
    private enum Side { case left, right }
    private var isUp = [Side.left: false, .right: false]
    private var isDown = [Side.left: false, .right: false]
    private var recentAngles = [Side.left: [Double](), .right: [Double]()]
    private var recentArmpitAngles = [Side.left: [Double](), .right: [Double]()]
    
    // MARK: - Thresholds
    private let upAngleThreshold: Double = 70.0    // bicep fully curled
    private let downAngleThreshold: Double = 160.0 // arm extended
    private let angleHysteresis: Double = 10.0     // prevents bouncing
    private let angleHistoryCount = 5             // smoothing window
    
    // NEW: Armpit angle thresholds
    private let maxArmpitAngle: Double = 45.0     // max degrees elbow can be away from torso
    private let armpitAngleHysteresis: Double = 5.0
    
    // MARK: - Constants
    private let goodCurlLabel = "Good Bicep Curl"
    private let minGoodCurlConfidence: Double = 0.8  // e.g. only count if ≥80%

    // MARK: - Types
    struct SetInfo {
        let currentSet: Int
        let totalSets: Int
        let reps: Int
        let weight: Double
    }
    
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
        setupPipeline()
        setupAudioPlayer()
        enableScreenWake()
    }
    
    // MARK: - Public Methods
    func cleanup() {
        stopAllTimers()
        videoCapture?.isEnabled = false
        cancellables.removeAll()
        disableScreenWake() // Disable screen wake when cleaning up
    }
    
    func setupPipeline() {
        videoProcessingChain = VideoProcessingChain()
        videoProcessingChain?.delegate = self
        
        videoCapture = VideoCapture()
        videoCapture?.delegate = self
    }
    
    func toggleCamera() {
        videoCapture?.toggleCameraSelection()
    }
    
    func updateOrientation() {
        videoCapture?.updateDeviceOrientation()
    }
    
    func stopCamera() {
        videoCapture?.isEnabled = false
    }
    
    func startCamera() {
        videoCapture?.isEnabled = true
    }
    
    func startExercise() {
        // Remove automatic start
        // Just initialize the state
        isExerciseActive = false
        isSessionCompleted = false
        isResting = false
        countdown = nil
        repCount = 0
        currentSet = 0
        resetRepCount()
    }
    
    func resetExercise() {
        stopAllTimers()
        self.startExercise()
    }
    
    private func setupAudioPlayer() {
        // Setup good curl sound
        guard let soundURL = Bundle.main.url(forResource: "good_curl", withExtension: "mp3") else {
            print("Could not find good curl sound file")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Could not create good curl audio player: \(error)")
        }
        
        // Setup completion sound
        guard let completionSoundURL = Bundle.main.url(forResource: "exercise_complete", withExtension: "mp3") else {
            print("Could not find completion sound file")
            return
        }
        
        do {
            completionAudioPlayer = try AVAudioPlayer(contentsOf: completionSoundURL)
            completionAudioPlayer?.prepareToPlay()
        } catch {
            print("Could not create completion audio player: \(error)")
        }
    }
    
    private func playGoodCurlSound() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    private func playCompletionSound() {
        completionAudioPlayer?.currentTime = 0
        completionAudioPlayer?.play()
    }
    
    // MARK: - Private Methods
    private func resetRepCount() {
        isUp = [Side.left: false, .right: false]
        isDown = [Side.left: false, .right: false]
        recentAngles = [Side.left: [], .right: []]
        recentArmpitAngles = [Side.left: [], .right: []]
    }
    
    private func startCountdown() {
        countdown = 3
        isCountingDown = true
        isExerciseActive = false
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            Task { @MainActor in
                if let currentCount = self.countdown {
                    if currentCount > 0 {
                        self.countdown = currentCount - 1
                    } else {
                        timer.invalidate()
                        self.isCountingDown = false
                        self.isExerciseActive = true
                        self.countdown = nil
                    }
                }
            }
        }
    }
    
    private func startRestTimer() {
        isResting = true
        restTimeRemaining = configuration.restTime
        
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            Task { @MainActor in
                if self.restTimeRemaining > 0 {
                    self.restTimeRemaining -= 1
                } else {
                    timer.invalidate()
                    self.isResting = false
                    self.repCount = 0
                    self.startCountdown()
                }
            }
        }
    }
    
    private func stopAllTimers() {
        restTimer?.invalidate()
        restTimer = nil
    }
    
    // MARK: - State Updates
    func handleCountdownChange() {
        if !isLastSet && countdown == nil {
            isExerciseActive = true
            currentSet += 1
        }
    }
    
    func handleRepetitionChange() {
        guard let currentConfig = currentSetConfig else { return }
        
        if repCount >= currentConfig.reps {
            stopAllTimers()
            if isLastSet {
                isExerciseActive = false
                isSessionCompleted = true
                playCompletionSound() // Play completion sound when session is done
            } else {
                startRestTimer()
            }
        }
    }
    
    // MARK: - View Helpers
    var currentSetInfo: SetInfo? {
        guard let currentConfig = currentSetConfig else { return nil }
        return SetInfo(
            currentSet: currentSet,
            totalSets: configuration.sets.count,
            reps: currentConfig.reps,
            weight: currentConfig.weight
        )
    }
    
    var totalReps: Int {
        configuration.sets.reduce(0) { $0 + $1.reps }
    }

    private func updateUI(with prediction: ActionPrediction) {
        actionLabel = prediction.label
        confidenceLabel = prediction.confidenceString ?? "Observing..."
    }

    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
        let currentTime = CACurrentMediaTime()
        guard currentTime - lastProcessedTime >= minimumProcessingInterval else {
            return // Skip this frame if we're processing too fast
        }
        lastProcessedTime = currentTime
        
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            let frameSize = CGSize(width: frame.width, height: frame.height)
            let rendererFormat = UIGraphicsImageRendererFormat()
            rendererFormat.scale = 1.0
            let renderer = UIGraphicsImageRenderer(size: frameSize, format: rendererFormat)

            let image = renderer.image { context in
                let cgContext = context.cgContext
                let inverse = cgContext.ctm.inverted()
                cgContext.concatenate(inverse)

                cgContext.draw(frame, in: CGRect(origin: .zero, size: frameSize))

                let transform = CGAffineTransform(scaleX: frameSize.width, y: frameSize.height)

                poses?.forEach { pose in
                    pose.drawWireframeToContext(cgContext, applying: transform)
                }
            }

            DispatchQueue.main.async {
                self.renderedImage = image
                
                if let poses = poses, !poses.isEmpty {
                    if !self.isExerciseActive {
                        if let firstPose = poses.first {
                            self.checkPosition(from: firstPose)
                        }
                    } else {
                        if let firstPose = poses.first {
                            self.calculateBicepCurlAngle(from: firstPose)
                        }
                    }
                }
            }
        }
    }
    
    private func calculateBicepCurlAngle(from pose: Pose) {
        // geometric rep detection
        let leftDidRep  = processCurl(side: .left, pose: pose)
        let rightDidRep = processCurl(side: .right, pose: pose)
        guard let currentConfig = currentSetConfig else { return }

        // only count if geometry AND model agrees it's a "good" curl
        let didGeometryRep = leftDidRep || rightDidRep
        let isGoodCurl = (actionLabel == goodCurlLabel)

        if didGeometryRep && isGoodCurl {
            if repCount < currentConfig.reps {
                repCount += 1
                playGoodCurlSound() // Play sound when a good curl is counted
            }
        }
    }

    private func processCurl(side: Side, pose: Pose) -> Bool {
        // choose joint names
        let shoulderKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftShoulder : .rightShoulder
        let elbowKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftElbow : .rightElbow
        let wristKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftWrist : .rightWrist

        // get elbow angle (shoulder-elbow-wrist)
        guard let rawElbowAngle = elbowAngleDegrees(from: pose,
                                                   shoulder: shoulderKey,
                                                   elbow: elbowKey,
                                                   wrist: wristKey)
        else { return false }

        // NEW: get armpit angle (torso-shoulder-elbow)
        guard let rawArmpitAngle = armpitAngleDegrees(from: pose, side: side)
        else { return false }

        // smooth elbow angles
        guard var elbowBuffer = recentAngles[side] else { return false }
        elbowBuffer.append(rawElbowAngle)
        if elbowBuffer.count > angleHistoryCount {
            elbowBuffer.removeFirst()
        }
        let smoothedElbowAngle = elbowBuffer.reduce(0, +) / Double(elbowBuffer.count)
        recentAngles[side] = elbowBuffer

        // smooth armpit angles
        guard var armpitBuffer = recentArmpitAngles[side] else { return false }
        armpitBuffer.append(rawArmpitAngle)
        if armpitBuffer.count > angleHistoryCount {
            armpitBuffer.removeFirst()
        }
        let smoothedArmpitAngle = armpitBuffer.reduce(0, +) / Double(armpitBuffer.count)
        recentArmpitAngles[side] = armpitBuffer

        if side == .right {
            currentAngle = smoothedElbowAngle
            currentArmpitAngle = smoothedArmpitAngle
        }

        // NEW: Check if armpit angle is acceptable throughout the movement
        let isArmpitAngleGood = smoothedArmpitAngle <= maxArmpitAngle + armpitAngleHysteresis
        
        // Update form feedback
        if !isArmpitAngleGood {
            formFeedback = "Keep your elbow closer to your body"
        } else {
            formFeedback = "Good form!"
        }

        // state machine: count on up-transition ONLY if armpit angle is good
        var didRep = false
        let isUp = isUp[side] ?? false
        let isDown = isDown[side] ?? false
        
        if !isUp && !isDown {
            // initialize based on current pose
            if smoothedElbowAngle >= downAngleThreshold - angleHysteresis {
                self.isDown[side] = true
            } else if smoothedElbowAngle <= upAngleThreshold + angleHysteresis {
                self.isUp[side] = true
            }
        } else if isUp {
            // moving from up to down
            if smoothedElbowAngle >= downAngleThreshold {
                self.isUp[side] = false
                self.isDown[side] = true
            }
        } else if isDown {
            // moving from down to up => count rep ONLY if armpit angle is good
            if smoothedElbowAngle <= upAngleThreshold {
                self.isDown[side] = false
                self.isUp[side] = true
                // NEW: Only count the rep if armpit angle was good throughout
                if isArmpitAngleGood {
                    didRep = true
                }
            }
        }
        return didRep
    }

    // NEW: Calculate armpit angle (angle between torso and upper arm)
    private func armpitAngleDegrees(from pose: Pose, side: Side) -> Double? {
        let shoulderKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftShoulder : .rightShoulder
        let elbowKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftElbow : .rightElbow
        
        // For torso reference, we'll use the vertical line from shoulder
        // In a proper bicep curl, the upper arm should stay close to vertical
        guard let shoulderPoint = pose.landmarks.first(where: { $0.name == shoulderKey })?.location,
              let elbowPoint = pose.landmarks.first(where: { $0.name == elbowKey })?.location
        else { return nil }
        
        // Calculate the angle between the upper arm (shoulder to elbow) and vertical
        // Vertical reference vector pointing down
        let verticalVector = CGVector(dx: 0, dy: -1) // negative because y increases downward in Vision coordinates
        let upperArmVector = CGVector(dx: elbowPoint.x - shoulderPoint.x, dy: elbowPoint.y - shoulderPoint.y)
        
        let dot = verticalVector.dx * upperArmVector.dx + verticalVector.dy * upperArmVector.dy
        let mag1 = sqrt(verticalVector.dx * verticalVector.dx + verticalVector.dy * verticalVector.dy)
        let mag2 = sqrt(upperArmVector.dx * upperArmVector.dx + upperArmVector.dy * upperArmVector.dy)
        
        guard mag1 > 1e-6, mag2 > 1e-6 else { return nil }
        
        let cosθ = max(-1.0, min(1.0, dot / (mag1 * mag2)))
        let angleInRadians = acos(cosθ)
        let angleInDegrees = angleInRadians * 180.0 / Double.pi
        
        return angleInDegrees
    }

    // Helper for three-point angle
    private func validKeypoints(
        _ joints: [VNHumanBodyPoseObservation.JointName],
        in pose: Pose
    ) -> [CGPoint]? {
        let pts = joints.compactMap { name -> CGPoint? in
            pose.landmarks.first(where: { $0.name == name })?.location
        }
        return pts.count == joints.count ? pts : nil
    }

    private func elbowAngleDegrees(
        from pose: Pose,
        shoulder: VNHumanBodyPoseObservation.JointName,
        elbow: VNHumanBodyPoseObservation.JointName,
        wrist: VNHumanBodyPoseObservation.JointName
    ) -> Double? {
        guard let pts = validKeypoints([shoulder, elbow, wrist], in: pose) else { return nil }
        let pointA = pts[0], pointB = pts[1], pointC = pts[2]
        let vector1 = CGVector(dx: pointA.x - pointB.x, dy: pointA.y - pointB.y)
        let vector2 = CGVector(dx: pointC.x - pointB.x, dy: pointC.y - pointB.y)
        let dot = vector1.dx * vector2.dx + vector1.dy * vector2.dy
        let mag1 = sqrt(vector1.dx * vector1.dx + vector1.dy * vector1.dy)
        let mag2 = sqrt(vector2.dx * vector2.dx + vector2.dy * vector2.dy)
        guard mag1 > 1e-6, mag2 > 1e-6 else { return nil }
        let cosθ = max(-1.0, min(1.0, dot / (mag1 * mag2)))
        return acos(cosθ) * 180.0 / Double.pi
    }

    private func addFrameCount(_ count: Int, to label: String) {
        actionFrameCounts[label, default: 0] += count
    }

    private func checkPosition(from pose: Pose) {
        // Track right arm only (shoulder, elbow, wrist)
        let shoulderKey: VNHumanBodyPoseObservation.JointName = .rightShoulder
        let elbowKey: VNHumanBodyPoseObservation.JointName = .rightElbow
        let wristKey: VNHumanBodyPoseObservation.JointName = .rightWrist

        // Extract normalized points
        guard
            let sPoint = pose.landmarks.first(where: { $0.name == shoulderKey })?.location,
            let ePoint = pose.landmarks.first(where: { $0.name == elbowKey })?.location,
            let wPoint = pose.landmarks.first(where: { $0.name == wristKey })?.location
        else {
            correctPositionStartTime = nil
            isInCorrectPosition = false
            positionFeedback = "Show your arm clearly"
            return
        }
        
        // Convert to view coordinates (origin top-left)
        func toView(_ point: CGPoint) -> CGPoint {
            CGPoint(x: point.x, y: 1 - point.y)
        }
        let shoulder = toView(sPoint)
        let elbow    = toView(ePoint)
        let wrist    = toView(wPoint)

        // Check horizontal guide band (e.g. center 60% of screen)
        let minX: CGFloat = 0.2, maxX: CGFloat = 0.8
        let inGuideBand = [shoulder.x, elbow.x, wrist.x].allSatisfy { $0 >= minX && $0 <= maxX }

        // Check that upper-arm vector (shoulder->elbow) is roughly vertical
        let vector = CGVector(dx: elbow.x - shoulder.x, dy: elbow.y - shoulder.y)
        let rawAngle = atan2(vector.dy, vector.dx) * 180 / .pi
        let sideOn = abs(abs(rawAngle) - 90) < 30

        let now = CACurrentMediaTime()
        if inGuideBand && sideOn {
            if correctPositionStartTime == nil {
                correctPositionStartTime = now
                positionFeedback = "Hold still for \(Int(requiredPositionHoldTime))s to start"
            }
            let elapsed = now - (correctPositionStartTime ?? now)
            if elapsed >= requiredPositionHoldTime {
                positionFeedback = "Starting exercise..."
                if !isExerciseActive && !isCountingDown {
                    startCountdown()
                }
            } else {
                let remaining = Int(ceil(requiredPositionHoldTime - elapsed))
                positionFeedback = "Hold still for \(remaining)s to start"
            }
            isInCorrectPosition = true
        } else {
            correctPositionStartTime = nil
            isInCorrectPosition = false
            positionFeedback = !inGuideBand ?
                "Move your arm into the guide" :
                "Turn sideways so your arm is vertical"
        }
    }

    // MARK: - Screen Wake
    private func enableScreenWake() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    private func disableScreenWake() {
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

// MARK: –– Delegates
extension ExerciseViewModel: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher) {
        updateUI(with: .startingPrediction)
        videoProcessingChain?.upstreamFramePublisher = framePublisher
    }
}

extension ExerciseViewModel: VideoProcessingChainDelegate {
    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didPredict actionPrediction: ActionPrediction,
                              for frameCount: Int) {
        if actionPrediction.isModelLabel {
            addFrameCount(frameCount, to: actionPrediction.label)
        }
        updateUI(with: actionPrediction)
    }

    func videoProcessingChain(_ chain: VideoProcessingChain,
                              didDetect poses: [Pose]?, in frame: CGImage) {
        drawPoses(poses, onto: frame)
    }
}
