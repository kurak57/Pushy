import SwiftUI

struct CountdownDisplay: View {
    let count: Int
    let isCountingDown: Bool

    var body: some View {
        Text(count == 0 ? "GO!" : "\(count)")
            .font(.system(size: 72, weight: .bold))
            .foregroundColor(.black)
            .scaleEffect(isCountingDown ? 1.2 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCountingDown)
    }
}

#Preview {
    CountdownDisplay(count: 3, isCountingDown: true)
} 