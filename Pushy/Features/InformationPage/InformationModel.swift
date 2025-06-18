//
//  InformationModel.swift
//  Pushy
//
//  Created by Andrea Octaviani on 18/06/25.
//

import SwiftUI

struct InformationModel: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let message: String
}
