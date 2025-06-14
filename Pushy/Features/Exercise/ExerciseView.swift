//
//  ExerciseView.swift
//  Pushy
//
//  Created by Mutakin on 13/06/25.
//

import SwiftUI

struct ExerciseView: View {
    //    @StateObject private var viewModel = ExerciseViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            //            if let image = viewModel.renderedImage {
            //                Image(uiImage: image)
            //                    .resizable()
            //                    .scaledToFit()
            //                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            //                    .background(Color.black)
            //            } else {
            //                Color.black
            //                    .overlay(Text("Starting Camera...").foregroundColor(.white))
            //            }

            //            VStack(spacing: 4) {
            //                Text(viewModel.actionLabel)
            //                    .font(.title)
            //                    .bold()
            //                    .foregroundColor(.white)
            //                Text(viewModel.confidenceLabel)
            //                    .font(.subheadline)
            //                    .foregroundColor(.gray)
            //            }
            //            .padding()
            //            .background(Color.black.opacity(0.6))
            //            .cornerRadius(12)

            // Add gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.7),
                    Color.black.opacity(0.3),
                    Color.clear,
                    Color.clear,
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            HStack {
                Button(action: {
                }) {
                    Image(systemName: "multiply")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                Spacer()
                Button(action: {
                }) {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .padding(12)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            GeometryReader { geo in
                VStack {
                    Spacer()
                    Image("PositionGuide")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width * 0.5, height: geo.size.height * 0.8)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color.green,
                                    lineWidth: 3
                                )
                        )
                }
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .init(horizontal: .center, vertical: .bottom))
                
            }

        }
    }
}

#Preview {
    ExerciseView()
}
