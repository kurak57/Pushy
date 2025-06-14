//
//  PoseViewModel.swift
//  Guess My Exercise
//
//  Created by Jehoiada Wong on 13/06/25.
//  Copyright © 2025 Apple. All rights reserved.
//


import Foundation
import Vision
import Combine
import UIKit

@MainActor
class ExerciseViewModel: ObservableObject {
    @Published var actionLabel: String = "Observing..."
    @Published var confidenceLabel: String = "Observing..."
    @Published var renderedImage: UIImage?

    private var videoCapture: VideoCapture!
    private var videoProcessingChain: VideoProcessingChain!
    private var cancellables = Set<AnyCancellable>()
    
    var actionFrameCounts = [String: Int]()

    init() {
        setupPipeline()
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
    }

    private func addFrameCount(_ count: Int, to label: String) {
        actionFrameCounts[label, default: 0] += count
    }
}

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
