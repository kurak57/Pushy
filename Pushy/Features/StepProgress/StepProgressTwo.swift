//
//  StepProgressTwo.swift
//  Pushy
//
//  Created by Tomi Timutius on 13/06/25.
//

import SwiftUI

struct StepProgressTwo: View {
    var StepsNum: Int = 3
    @State var CurrentStep: Int = 2
    
    
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                ForEach(0..<StepsNum, id: \.self) { item in
                    Circle()
                    
                        .stroke(lineWidth: item <= CurrentStep ? 5 : 5)
                        .frame(width: 50, height: item == CurrentStep ? 50 : 50)
                        .foregroundStyle(item < CurrentStep ? .green : .gray)
//                        .overlay {
//                            if item == CurrentStep {
//                                Image(systemName: "checkmark")
//                                    .font(.title2)
//                                    .foregroundStyle(.white)
//                                    .transition(.scale)
//                            }
//                        }

                    if item < StepsNum - 1 {
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .frame(height: 20)
                                .foregroundStyle(.gray)

                            Rectangle()
                                .frame(height: 20)
                                .frame(maxWidth: item >= CurrentStep ? 0 : .infinity, alignment: .leading)
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 50)
            
            HStack {
                Button {
                    subtractOne()
                    print(CurrentStep)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                Spacer()
                Button {
                    addOne()
                    print(CurrentStep)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(.green)
                }

            }
            .padding(20)
        }

    }
    
    private func addOne() {
        CurrentStep += 1
    }
    private func subtractOne(){
        CurrentStep -= 1
    }
}

#Preview {
    StepProgressTwo()
}
