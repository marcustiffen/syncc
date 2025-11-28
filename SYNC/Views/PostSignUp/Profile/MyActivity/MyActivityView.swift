import SwiftUI
import FirebaseFirestore


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
                ForEach(viewModel.activities) { activity in
                    MyActivityCardView(
                        activity: activity,
                        viewModel: viewModel
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            Task {
                                try await viewModel.deleteActivity(
                                    currentUserId: profileModel.user?.uid ?? "",
                                    activity: activity
                                )
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .onAppear {
                        if viewModel.shouldLoadMore(currentActivity: activity) {
                            Task {
                                await viewModel.loadMoreActivities(currentUserId: profileModel.user?.uid ?? "")
                            }
                        }
                    }
                }
                
                if viewModel.isLoadingMore {
                    HStack(spacing: 12) {
                        ProgressView()
                        Text("Loading more...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)
                }
                
                if !viewModel.hasMoreActivities && !viewModel.activities.isEmpty {
                    Text("No more activities to show!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }
            }
            .padding(.vertical, 16)
        }
        .refreshable {
            await viewModel.refresh(currentUserId: profileModel.user?.uid ?? "")
        }
    }
}
