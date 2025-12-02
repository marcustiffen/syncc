//import SwiftUI
//
//
//struct ActivityFilterBar: View {
//    @EnvironmentObject var profileModel: ProfileModel
//    @ObservedObject var viewModel: ActivityViewModel
//    @State private var searchText = ""
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            // Search bar
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.secondary)
//                
//                TextField("Search activities...", text: $searchText)
//                    .textFieldStyle(.plain)
//                    .autocorrectionDisabled()
//                    .onChange(of: searchText) { newValue, oldValue in
//                        viewModel.updateSearchText(newValue)
//                    }
//                
//                if !searchText.isEmpty {
//                    Button {
//                        searchText = ""
//                        viewModel.updateSearchText("")
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//            .padding(10)
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
//            
//            // Active filter indicator
//            if viewModel.filter.isActive {
//                HStack {
//                    Text(filterSummary)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Spacer()
//                    
//                    Button("Clear All") {
//                        searchText = ""
//                        Task {
//                            await viewModel.clearFilters(currentUserId: profileModel.user?.uid ?? "")
//                        }
//                    }
//                    .font(.caption)
//                    .foregroundColor(.blue)
//                }
//            }
//        }
//        .padding(.horizontal, 10)
//        .padding(.vertical, 8)
//        .onAppear {
//            searchText = viewModel.filter.searchText
//        }
//    }
//    
//    private var filterSummary: String {
//        var parts: [String] = []
//        
//        if let radius = viewModel.filter.radiusKm {
//            parts.append("\(Int(radius))km radius")
//        }
//        
//        if viewModel.filter.dateRange != .all {
//            parts.append(viewModel.filter.dateRange.displayName)
//        }
//        
//        if !viewModel.filter.searchText.isEmpty {
//            parts.append("Search: '\(viewModel.filter.searchText)'")
//        }
//        
//        return parts.joined(separator: " • ")
//    }
//}



import SwiftUI


struct ActivityFilterBar: View {
    @EnvironmentObject var profileModel: ProfileModel
    @ObservedObject var viewModel: ActivityViewModel
    
    // ✅ FIXED: Use @State to track local search text without debounce
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Search bar
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.secondary)
//                
//                TextField("Search activities...", text: $searchText)
//                    .textFieldStyle(.plain)
//                    .autocorrectionDisabled()
//                    .onChange(of: searchText) { oldValue, newValue in
//                        // ✅ FIXED: Update view model immediately
//                        viewModel.updateSearchText(newValue)
//                    }
//                
//                if !searchText.isEmpty {
//                    Button {
//                        searchText = ""
//                        viewModel.updateSearchText("")
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//            .padding(10)
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
            
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
        
        // ✅ FIXED: Use local searchText to show current typing
        if !searchText.isEmpty {
            parts.append("Search: '\(searchText)'")
        }
        
        return parts.joined(separator: " • ")
    }
}
