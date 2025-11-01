struct EmptyFilterResultsView: View {
    let onClearFilters: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No activities found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Try adjusting your filters to see more activities")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Clear Filters") {
                onClearFilters()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
