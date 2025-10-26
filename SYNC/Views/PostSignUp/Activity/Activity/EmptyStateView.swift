import SwiftUI


struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No Activities Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Activities from your matches will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
