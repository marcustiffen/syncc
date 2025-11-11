import Foundation
import CoreLocation
import SwiftUI




struct ActivityView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @EnvironmentObject var profileModel: ProfileModel
    
    var body: some View {
        VStack(spacing: 0) {
            titleView()
                .padding(.top, 50)
                .padding(.horizontal, 10)
            
            // Filter bar
            ActivityFilterBar(viewModel: viewModel)
                .transition(.move(edge: .top).combined(with: .opacity))
            
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
            } else if viewModel.filteredActivities.isEmpty {
                Spacer()
                if viewModel.filter.isActive {
                    EmptyFilterResultsView {
                        Task {
                            await viewModel.clearFilters(currentUserId: profileModel.user?.uid ?? "")
                        }
                    }
                } else {
                    EmptyStateView()
                }
                Spacer()
            } else {
                activitiesScrollView()
            }
        }
        .sheet(isPresented: $viewModel.showFilterSheet) {
            NavigationStack {
                ActivityFilterSheet(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
                // ✅ FIXED: Set user location when view appears
                if let location = profileModel.user?.location {
                    viewModel.updateUserLocation(location)
                    print("✅ User location set on appear: \(location.name)")
                }
                
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
            
            // Filter indicator badge
            Button {
                viewModel.showFilterSheet = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                    
                    if viewModel.filter.isActive {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
    
    private func activitiesScrollView() -> some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredActivities) { activity in
                    ActivityCardView(activity: activity, viewModel: viewModel)
                        .environmentObject(profileModel)
                        .onAppear {
                            if activity == viewModel.filteredActivities.last {
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
                } else if !viewModel.hasMoreActivities && !viewModel.filteredActivities.isEmpty {
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
