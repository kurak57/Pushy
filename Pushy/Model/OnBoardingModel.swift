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
        description: "Connect Bluetooth earphones for real-time voice feedback",
        subtext: "No earphones? You can still continue"
    ),
    OnboardingModel(
        imageName: "tripod",
        title: "Set Your Phone",
        description: "Place it where your full body is visible—tripod, mirror, or stable surface",
        subtext: "Make sure the phone is steady and won’t fall during your workout"
    ),
    OnboardingModel(
        imageName: "body",
        title: "Align with Silhouette",
        description: "Stand still and match your body to the outline",
        subtext: "The outline turns white when you’re in the right spot"
    )
]
