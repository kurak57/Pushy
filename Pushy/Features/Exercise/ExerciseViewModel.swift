import Foundation
import Vision
import Combine
import UIKit
import SwiftUI

@MainActor
class ExerciseViewModel: ObservableObject {
    // MARK: - ML State
    @Published var actionLabel: String = "Observing..."
    @Published var confidenceLabel: String = "Observing..."
    @Published var renderedImage: UIImage?
    @Published var repCount: Int = 0
    @Published var currentAngle: Double = 0.0
    
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
    
    // MARK: - Per‑arm rep‑counting state
    private enum Side { case left, right }
    private var isUp = [Side.left: false, .right: false]
    private var isDown = [Side.left: false, .right: false]
    private var recentAngles = [Side.left: [Double](), .right: [Double]()]
    
    // MARK: - Thresholds
    private let upAngleThreshold: Double = 70.0    // bicep fully curled
    private let downAngleThreshold: Double = 160.0 // arm extended
    private let angleHysteresis: Double = 10.0     // prevents bouncing
    private let angleHistoryCount = 5             // smoothing window
    
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
    }
//
//    deinit {
//        Task { @MainActor in
//            cleanup()
//        }
//    }
    
    // MARK: - Public Methods
    func cleanup() {
        stopAllTimers()
        videoCapture?.isEnabled = false
        cancellables.removeAll()
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
        isExerciseActive = false
        isSessionCompleted = false
        isResting = false
        countdown = nil
        repCount = 0
        currentSet = 0
        resetRepCount()
        
        // Start the exercise again after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startExercise()
        }
    }
    
    // MARK: - Private Methods
    private func resetRepCount() {
        isUp = [Side.left: false, .right: false]
        isDown = [Side.left: false, .right: false]
        recentAngles = [Side.left: [], .right: []]
    }
    
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
    
    
    private func startRestTimer() {
        isResting = true
        restTimeRemaining = configuration.restTime
        
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
                self.repCount = 0
                self.startCountdown()
            }
        }
    }
    
    private func stopAllTimers() {
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
            }
        }
    }
    
    func handleRepetitionChange() {
        guard let currentConfig = currentSetConfig else { return }
        
        if repCount >= currentConfig.reps {
            stopAllTimers()
            if isLastSet {
                isExerciseActive = false
                isSessionCompleted = true
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
        let leftDidRep  = processCurl(side: .left,  pose: pose)
        let rightDidRep = processCurl(side: .right, pose: pose)
        guard let currentConfig = currentSetConfig else { return }

        // only count if geometry AND model agrees it's a "good" curl
        let didGeometryRep = leftDidRep || rightDidRep
        let isGoodCurl = (actionLabel == goodCurlLabel)

        if didGeometryRep && isGoodCurl {
            if repCount < currentConfig.reps {
                repCount += 1
            }
        }
    }

    private func processCurl(side: Side, pose: Pose) -> Bool {
        // choose joint names
        let shoulderKey: VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftShoulder : .rightShoulder
        let elbowKey:    VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftElbow    : .rightElbow
        let wristKey:    VNHumanBodyPoseObservation.JointName = (side == .left) ? .leftWrist    : .rightWrist

        // get angle
        guard let rawAngle = elbowAngleDegrees(from: pose,
                                               shoulder: shoulderKey,
                                               elbow: elbowKey,
                                               wrist: wristKey)
        else { return false }

        // smooth
        guard var buffer = recentAngles[side] else {
            return false
        }

        buffer.append(rawAngle)
        if buffer.count > angleHistoryCount {
            buffer.removeFirst()
        }
        let smoothed = buffer.reduce(0, +) / Double(buffer.count)
        recentAngles[side] = buffer

        if side == .right { currentAngle = smoothed }

        // state machine: count on up-transition
        var didRep = false
        let isUp = isUp[side] ?? false
        let isDown = isDown[side] ?? false
        
        if !isUp && !isDown {
            // initialize based on current pose
            if smoothed >= downAngleThreshold - angleHysteresis {
                self.isDown[side] = true
            } else if smoothed <= upAngleThreshold + angleHysteresis {
                self.isUp[side] = true
            }
        } else if isUp {
            // moving from up to down
            if smoothed >= downAngleThreshold {
                self.isUp[side] = false
                self.isDown[side] = true
            }
        } else if isDown {
            // moving from down to up => count rep
            if smoothed <= upAngleThreshold {
                self.isDown[side] = false
                self.isUp[side] = true
                didRep = true
            }
        }
        return didRep
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
        elbow:    VNHumanBodyPoseObservation.JointName,
        wrist:    VNHumanBodyPoseObservation.JointName
    ) -> Double? {
        guard let pts = validKeypoints([shoulder, elbow, wrist], in: pose) else { return nil }
        let pA = pts[0], pB = pts[1], pC = pts[2]
        let v1 = CGVector(dx: pA.x - pB.x, dy: pA.y - pB.y)
        let v2 = CGVector(dx: pC.x - pB.x, dy: pC.y - pB.y)
        let dot = v1.dx * v2.dx + v1.dy * v2.dy
        let mag1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy)
        let mag2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy)
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
        let elbowKey:    VNHumanBodyPoseObservation.JointName = .rightElbow
        let wristKey:    VNHumanBodyPoseObservation.JointName = .rightWrist

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
        func toView(_ p: CGPoint) -> CGPoint {
            CGPoint(x: p.x, y: 1 - p.y)
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

    
    private func calculateAngle(p1: CGPoint, p2: CGPoint) -> Double {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let angle = atan2(dy, dx) * 180 / Double.pi
        // Normalize angle to be between 0 and 180 degrees
        return (angle + 360).truncatingRemainder(dividingBy: 180)
    }
    
    private func distance(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        return sqrt(dx * dx + dy * dy)
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
