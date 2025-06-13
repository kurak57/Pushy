//
//  ContentView.swift
//  Pushy
//
//  Created by Tomi Timutius on 12/06/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Bicep Curl")
            Image(systemName: "video")
            Text("Notes")
            HStack {
                Image(systemName: "clock")
                Text("Rest Timer: OFF")
            }
            HStack {
                Text("Sets: 3")
                Text("KG: 85")
                Text("Reps: 12")
            }
            HStack {
                Text("Sets: 3")
                Text("KG: 85")
                Text("Reps: 12")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
