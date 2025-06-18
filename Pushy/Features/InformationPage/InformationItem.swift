//
//  InformationItem.swift
//  Pushy
//
//  Created by Andrea Octaviani on 18/06/25.
//

import SwiftUI

struct InformationItem: View {
    let item: InformationModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text(item.icon)
                .font(.roundedmplus(size: 48))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.roundedmplus(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(item.message)
                    .font(.roundedmplus(size: 17))
                    .foregroundColor(.gray.opacity(1))
            }
        }
    }
}

#Preview {
    InformationItem(item: .init(icon: "💪", title: "Track Bicep Curls Only", message: "For now, the app is built just for bicep curls—works best in bright, open spaces."))
}
