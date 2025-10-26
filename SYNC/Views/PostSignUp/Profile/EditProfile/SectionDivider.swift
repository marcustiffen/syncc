import SwiftUI

struct SectionDivider: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.syncBlack.opacity(0.1))
                .frame(height: 2)
            Spacer()
        }
    }
}
