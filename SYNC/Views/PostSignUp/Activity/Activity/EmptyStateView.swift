import SwiftUI


struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle")
                .h1Style()
                .foregroundColor(.secondary)
            Text("No Activities Yet")
                .h2Style()
                .fontWeight(.semibold)
            Text("Activities from your matches will appear here")
                .bodyTextStyle()
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
