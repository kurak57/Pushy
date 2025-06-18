//
//  OnBoardingModel.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import Foundation

struct OnboardingModel: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
    let subtext: String?
}

let onboardingModel: [OnboardingModel] = [
    OnboardingModel(
        imageName: "tws",
        title: "Use Earphones",
        description: "Connect Bluetooth earphones for better experience",
        subtext: "No earphones? You can still continue"
    ),
    OnboardingModel(
        imageName: "Set Your Phone",
        title: "Set Your Phone",
        description: "Use a tripod, stick your phone to a mirror, or lean it on something stable",
        subtext: "Make sure the phone is steady and won’t fall during your workout"
    ),
    OnboardingModel(
        imageName: "Be Ready!",
        title: "Align with Silhouette",
        description: "When you’re ready, tap “Get Started”",
        subtext: "Then, align your body with the silhouette to begin calibration"
    )
]
