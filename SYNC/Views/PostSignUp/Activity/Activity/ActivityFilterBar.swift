import SwiftUI


struct ActivityFilterBar: View {
    @EnvironmentObject var profileModel: ProfileModel
    @ObservedObject var viewModel: ActivityViewModel
    

    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Active filter indicator
            if viewModel.filter.isActive {
                HStack {
                    Text(filterSummary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Clear All") {
                        searchText = ""
                        Task {
                            await viewModel.clearFilters(currentUserId: profileModel.user?.uid ?? "")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .onAppear {
            // Sync initial value from view model
            searchText = viewModel.filter.searchText
        }
    }
    
    private var filterSummary: String {
        var parts: [String] = []
        
        if let radius = viewModel.filter.radiusKm {
            parts.append("\(Int(radius))km radius")
        }
        
        if viewModel.filter.dateRange != .all {
            parts.append(viewModel.filter.dateRange.displayName)
        }
        

        if !searchText.isEmpty {
            parts.append("Search: '\(searchText)'")
        }
        
        return parts.joined(separator: " • ")
    }
}
