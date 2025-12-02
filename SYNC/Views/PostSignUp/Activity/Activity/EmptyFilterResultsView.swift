import SwiftUI


struct EmptyFilterResultsView: View {
    let onClearFilters: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No upcoming activities found")
                .font(.h1)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Try adjusting your filters to see more activities or find more connections!")
                .font(.h2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
//            Button("Clear Filters") {
//                onClearFilters()
//            }
//            .buttonStyle(.borderedProminent)
            
            Button {
                onClearFilters()
            } label: {
                Text("Clear Filters")
                    .padding(5)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.red)
                    )
            }

        }
        .padding()
    }
}
