import SwiftUI

struct RepetitionCounterView: View {
    var label: String = "Repetition"
    var value: Int

    @State private var previousValue: Int = 0
    @State private var animate = false

    var body: some View {
        VStack(spacing: 4) {
            // label
            Text(label)
                .font(.title2)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .background(Color.black)
                .cornerRadius(4)

            // background
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black)
                    .frame(width: 50, height: 60)

                // Animation Number
                ZStack {
                    Text("\(previousValue)")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .offset(y: animate ? -40 : 0)
                        .opacity(animate ? 0: 1)
                    
                    Text("\(value)")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .offset(y: animate ? 0 : 40)
                        .opacity(animate ? 1 : 0)
                        .scaleEffect(animate ? 1.05 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 500, damping: 15), value: animate)
                }
            }
            
        }
        .onChange(of: value) { prevValue, newValue in
            animate = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animate = true
            }
        }
    }
}

struct counterView: View {
    @State private var count = 0

    var body: some View {
        VStack(spacing: 20) {
            RepetitionCounterView(value: count)

            Button("Tambah Repetisi") {
                count += 1
            }
            Button("Reset") {
                count = 0
            }
            .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}

#Preview {
    counterView()
}
