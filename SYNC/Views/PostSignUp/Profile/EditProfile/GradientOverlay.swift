import SwiftUI

struct GradientOverlay: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, .syncBlack.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 30)
            .allowsHitTesting(false)
    }
}
