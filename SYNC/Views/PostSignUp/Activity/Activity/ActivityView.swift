import Foundation
import CoreLocation
import SwiftUI

struct ActivityView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @EnvironmentObject var profileModel: ProfileModel
    
    // ✅ NEW: Track if search bar is focused
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            titleView()
                .padding(.top, 50)
                .padding(.horizontal, 10)
            
            // ✅ NEW: Search bar with explicit search button
            searchBarView()
                .padding(.horizontal, 10)
                .padding(.top, 8)
            
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
        .ignoresSafeArea(.keyboard)
        .onTapGesture {
            dismissKeyboard()
        }
        .sheet(isPresented: $viewModel.showFilterSheet) {
            NavigationStack {
                ActivityFilterSheet(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
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
    
    // ✅ NEW: Search bar with explicit action button
    private func searchBarView() -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search activities...", text: $viewModel.searchText)
                    .focused($isSearchFocused)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch()
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.clearSearch()
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            
            // ✅ Search button - only show when there's text
            if !viewModel.searchText.isEmpty {
                Button {
                    performSearch()
                } label: {
                    Text("Search")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.syncBlack)
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.searchText.isEmpty)
    }
    
    // ✅ NEW: Perform search action
    private func performSearch() {
        isSearchFocused = false
        viewModel.executeSearch()
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
                            .fill(Color.syncGreen)
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
                // ✅ Show active search indicator
                if !viewModel.filter.searchText.isEmpty {
                    HStack {
                        Text("Results for: \"\(viewModel.filter.searchText)\"")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            viewModel.clearSearch()
                        } label: {
                            Text("Clear")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
                }
                
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
