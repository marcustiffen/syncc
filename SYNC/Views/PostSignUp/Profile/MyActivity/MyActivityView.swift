import SwiftUI
import FirebaseFirestore


@MainActor
class MyActivityViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var isLoadingInitial = false
    @Published var isLoadingMore = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var hasMoreActivities = true
    
    private let activityManager = ActivityManager.shared
    private let pageSize = 5
    
        
    func loadInitialActivities(currentUserId: String) async {
        guard !isLoadingInitial else { return }
        
        isLoadingInitial = true
        errorMessage = nil
        
        do {
            let fetchedActivities = try await activityManager.fetchMyActivities(
                userId: currentUserId,
                limit: pageSize
            )
            
            activities = fetchedActivities
            hasMoreActivities = fetchedActivities.count >= pageSize
            
        } catch {
            errorMessage = "Failed to load activities: \(error.localizedDescription)"
            print("Error loading initial activities: \(error)")
        }
        
        isLoadingInitial = false
    }
    

    func loadMoreActivities(currentUserId: String) async {
        guard !isLoadingMore && !isLoadingInitial && hasMoreActivities else { return }
        
        isLoadingMore = true
        
        do {
            let newActivities = try await activityManager.loadMoreMyActivities(
                userId: currentUserId,
                limit: pageSize
            )
            
            if !newActivities.isEmpty {
                // Remove duplicates and append
                let uniqueNew = newActivities.filter { newActivity in
                    !activities.contains(where: { $0.id == newActivity.id })
                }
                activities.append(contentsOf: uniqueNew)
                hasMoreActivities = newActivities.count >= pageSize
            } else {
                hasMoreActivities = false
            }
            
        } catch {
            print("Error loading more activities: \(error)")
        }
        
        isLoadingMore = false
    }
    
    
    func refresh(currentUserId: String) async {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        activityManager.resetPagination()
        
        do {
            let fetchedActivities = try await activityManager.fetchMyActivities(
                userId: currentUserId,
                limit: pageSize
            )
            
            activities = fetchedActivities
            hasMoreActivities = fetchedActivities.count >= pageSize
            errorMessage = nil
            
        } catch {
            errorMessage = "Failed to refresh: \(error.localizedDescription)"
            print("Error refreshing activities: \(error)")
        }
        
        isRefreshing = false
    }
    
    
    func shouldLoadMore(currentActivity: Activity) -> Bool {
        guard let index = activities.firstIndex(where: { $0.id == currentActivity.id }) else {
            return false
        }
        
        // Trigger load when user is 2 items away from the end
        return index >= activities.count - 2
    }
    
    
    func deleteActivity(currentUserId: String, activity: Activity) async throws {
        try await activityManager.deleteActivity(userId: currentUserId, id: activity.id)
    }
}



struct MyActivityView: View {
    @StateObject private var viewModel = MyActivityViewModel()
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileModel: ProfileModel
    
    var body: some View {
        VStack {
            Spacer()
            if viewModel.isLoadingInitial {
                loadingView
                Spacer()
            } else if viewModel.activities.isEmpty {
                emptyStateView
                Spacer()
            } else {
                activitiesListView
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.loadInitialActivities(currentUserId: profileModel.user?.uid ?? "")
        }
    }
    
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading activities...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Activities Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start by creating an activity or\nwait for your matches to post one!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .refreshable {
            await viewModel.refresh(currentUserId: profileModel.user?.uid ?? "")
        }
    }
    

    
    private var activitiesListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(viewModel.activities.enumerated()), id: \.element.id) { index, activity in
                    MyActivityCardView(viewModel: viewModel, activity: activity)
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    try await viewModel.deleteActivity(currentUserId: profileModel.user?.uid ?? "", activity: activity)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.05), value: viewModel.activities.count)
                        .onAppear {
                            if viewModel.shouldLoadMore(currentActivity: activity) {
                                Task {
                                    await viewModel.loadMoreActivities(currentUserId: profileModel.user?.uid ?? "")
                                }
                            }
                        }
                }
                
                // Loading More Indicator
                if viewModel.isLoadingMore {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Loading more...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
                
                // End of List Indicator
                if !viewModel.hasMoreActivities && !viewModel.activities.isEmpty {
                    Text("No more activities to show!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 16)
        }
        .refreshable {
            await viewModel.refresh(currentUserId: profileModel.user?.uid ?? "")
        }
    }
}



struct MyActivityCardView: View {
    
    @EnvironmentObject var profileModel: ProfileModel
    
    @ObservedObject var viewModel: MyActivityViewModel
        
    @State private var showComments: Bool = false
    
    let activity: Activity
    
    private var participantCount: Int {
        activity.participants.count
    }
    
    private var statusColor: Color {
        switch activity.status.lowercased() {
        case "upcoming":
            return .blue
        case "completed":
            return .green
        case "canceled":
            return .red
        default:
            return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                if let image = profileModel.user?.images?.first {
                    ImageLoaderView(urlString: image.url)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                }
                
                VStack(alignment: .leading) {
                    if let name = profileModel.user?.name {
                        Text(name)
                            .h2Style()
                            .bold()
                    }
                    HStack {
                        Text("Start time: \(formatDate(activity.startTime))")
                            .bodyTextStyle()
                        
                        Spacer()
                        Text(timeAgoString(from: activity.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(activity.name)
                .h2Style()
                .fontWeight(.semibold)
            
            if let description = activity.description {
                Text(description)
                    .h2Style()
                    .foregroundColor(.secondary)
            }
            
            if let location = activity.location {
                Label(location.name, systemImage: "location.fill")
                    .h2Style()
                    .foregroundColor(.secondary)
            }
            
            if let location = activity.location {
                ActivityMapView(location: location)
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
            }
            
            HStack {
                
                Spacer()
                
                Button {
                    showComments = true
                    print("Show comments")
                } label: {
                    Image(systemName: "bubble")
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle().fill(.syncWhite)
                        )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showComments) {
            CommentsView(activity: activity)
                .presentationDetents([.medium, .large])
        }
    }
    
    
    
    private func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        
        switch seconds {
        case 0..<60:
            return "\(seconds)s"
        case 60..<3600:
            return "\(seconds / 60)m"
        case 3600..<86400:
            return "\(seconds / 3600)h"
        case 86400..<604800:
            return "\(seconds / 86400)d"
        default:
            return "\(seconds / 604800)w"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
