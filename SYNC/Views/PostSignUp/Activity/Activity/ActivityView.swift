import SwiftUI







struct ActivityView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @EnvironmentObject var profileModel: ProfileModel
    
    
    var body: some View {
        VStack(spacing: 0) {
            titleView()
                .padding(.top, 50)
                .padding(.horizontal, 10)
            
            if viewModel.isLoading {
                Spacer()
                ProgressView("Loading activities...")
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                Spacer()
                ErrorView(message: errorMessage) {
                    Task {
                        await viewModel.refreshActivities(currentUserId: profileModel.user?.uid ?? "")
                    }
                }
                Spacer()
            } else if viewModel.activities.isEmpty {
                Spacer()
                EmptyStateView()
                Spacer()
            } else {
                activitiesScrollView()
            }
        }
        .onAppear {
            Task {
                await viewModel.loadInitialActivities(currentUserId: profileModel.user?.uid ?? "")
            }
        }
        .onDisappear {
            viewModel.stopListening(currentUserId: profileModel.user?.uid ?? "")
        }
    }
    
    
    private func titleView() -> some View {
        HStack {
            Text("Activity")
            Spacer()
            
            NavigationLink(
                destination: ActivityFilterView()
                    .environmentObject(profileModel)
            ) {
                Image(systemName: "slider.horizontal.below.rectangle")
            }
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
    
    
    private func activitiesScrollView() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.activities) { activity in
                    ActivityCardView(activity: activity, viewModel: viewModel)
                        .environmentObject(profileModel)
                        .onAppear {
                            if activity == viewModel.activities.last {
                                Task {
                                    await viewModel.loadMoreActivities(currentUserId: profileModel.user?.uid ?? "")
                                }
                            }
                        }
                }
                
                // Loading indicator at bottom
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                } else if !viewModel.hasMoreActivities && !viewModel.activities.isEmpty {
                    Text("No more activities")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 16)
        }
        .refreshable {
            await viewModel.refreshActivities(currentUserId: profileModel.user?.uid ?? "")
        }
    }
}









