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
    
    // MARK: - Private Properties
    private var videoCapture: VideoCapture!
    private var videoProcessingChain: VideoProcessingChain!
    private var cancellables = Set<AnyCancellable>()
    private var actionFrameCounts = [String: Int]()
    private var restTimer: Timer?
    private let configuration: ExerciseConfiguration
    
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
        videoProcessingChain.delegate = self
        
        videoCapture = VideoCapture()
        videoCapture.delegate = self
    }
    
    func toggleCamera() {
        videoCapture.toggleCameraSelection()
    }
    
    func updateOrientation() {
        videoCapture.updateDeviceOrientation()
    }
    
    func stopCamera() {
        videoCapture.isEnabled = false
    }
    
    func startCamera() {
        videoCapture.isEnabled = true
    }
    
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
                if configuration.isRestTimerEnabled {
                    startRestTimer()
                } else {
                    repCount = 0
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

    private func updateUI(with prediction: ActionPrediction) {
        actionLabel = prediction.label
        confidenceLabel = prediction.confidenceString ?? "Observing..."
    }

    private func drawPoses(_ poses: [Pose]?, onto frame: CGImage) {
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

        self.renderedImage = image
        
        if let poses = poses, !poses.isEmpty {
            calculateBicepCurlAngle(from: poses.first!)
        }
    }
    
    private func calculateBicepCurlAngle(from pose: Pose) {
        let leftDidRep  = processCurl(side: .left,  pose: pose)
        let rightDidRep = processCurl(side: .right, pose: pose)
        guard let currentConfig = currentSetConfig else { return }

        if leftDidRep || rightDidRep {
            
            if self.repCount < currentConfig.reps {
                self.repCount += 1
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
        var buffer = recentAngles[side]!
        buffer.append(rawAngle)
        if buffer.count > angleHistoryCount {
            buffer.removeFirst()
        }
        let smoothed = buffer.reduce(0, +) / Double(buffer.count)
        recentAngles[side] = buffer

        if side == .right { currentAngle = smoothed }

        // state machine: count on up-transition
        var didRep = false
        if !isUp[side]! && !isDown[side]! {
            // initialize based on current pose
            if smoothed >= downAngleThreshold - angleHysteresis {
                isDown[side] = true
            } else if smoothed <= upAngleThreshold + angleHysteresis {
                isUp[side] = true
            }
        } else if isUp[side]! {
            // moving from up to down
            if smoothed >= downAngleThreshold {
                isUp[side] = false
                isDown[side] = true
            }
        } else if isDown[side]! {
            // moving from down to up => count rep
            if smoothed <= upAngleThreshold {
                isDown[side] = false
                isUp[side] = true
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
}

// MARK: –– Delegates

extension ExerciseViewModel: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCreate framePublisher: FramePublisher) {
        updateUI(with: .startingPrediction)
        videoProcessingChain.upstreamFramePublisher = framePublisher
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
