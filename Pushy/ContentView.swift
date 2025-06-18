//
//  ContentView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var hasSeenFeatureInfo = false
    
    var body: some View {
        Group {
            if hasSeenFeatureInfo {
                HomeView()
            } else {
                InformationView(onFinish: {
                    hasSeenFeatureInfo = true
                })
            }
        }
    }
}

#Preview {
    ContentView()
}
