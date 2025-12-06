import SwiftUI
import CoreLocation
import Combine

@MainActor
class ActivityViewModel: ObservableObject {
    
    @Published var activities: [Activity] = []
    @Published var filteredActivities: [Activity] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMoreActivities = true
    @Published var filter = ActivityFilter()
    @Published var showFilterSheet = false
    

    @Published var searchText: String = ""
    
    private let activityManager = ActivityManager.shared
    private var matchedUserIds: [String] = []
    private var allActivities: [Activity] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupFilterObserver()
    }
    
    // MARK: - Filter Setup
    
    private func setupFilterObserver() {

        // Removed debounce since we're now filtering on explicit action
        $filter
            .removeDuplicates()
            .sink { [weak self] newFilter in
                guard let self = self else { return }
                Task { @MainActor in
                    await self.applyFilters()
                }
            }
            .store(in: &cancellables)
    }
    

    func executeSearch() {
        filter.searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    

    func clearSearch() {
        searchText = ""
        filter.searchText = ""
    }
    
    func loadInitialActivities(currentUserId: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            matchedUserIds = try await activityManager.fetchMatchedUserIds(userId: currentUserId)
            matchedUserIds.append(currentUserId)
            
            guard !matchedUserIds.isEmpty else {
                activities = []
                filteredActivities = []
                allActivities = []
                isLoading = false
                return
            }
            
            let fetchedActivities = try await activityManager.fetchInitialActivities(
                currentUserId: currentUserId,
                matchedUserIds: matchedUserIds,
                dateRange: filter.dateRange,
                limit: 20
            )
            
            print("\(fetchedActivities.count) initial activities loaded")
            
            allActivities = fetchedActivities
            activities = fetchedActivities
            
            await applyFilters()
            
        } catch {
            errorMessage = "Failed to load activities: \(error.localizedDescription)"
            print("❌ Error loading activities: \(error)")
        }
        
        isLoading = false
    }
    
    func loadMoreActivities(currentUserId: String) async {
        guard !isLoadingMore && hasMoreActivities else { return }
        
        isLoadingMore = true
        
        do {
            let moreActivities = try await activityManager.loadMoreActivities(
                currentUserId: currentUserId,
                matchedUserIds: matchedUserIds,
                dateRange: filter.dateRange,
                limit: 20
            )
            
            let newActivities = moreActivities.filter { newActivity in
                !allActivities.contains { $0.id == newActivity.id }
            }
            
            allActivities.append(contentsOf: newActivities)
            activities.append(contentsOf: newActivities)
            
            await applyFilters()
            
            hasMoreActivities = !moreActivities.isEmpty
            
        } catch {
            errorMessage = "Failed to load more activities: \(error.localizedDescription)"
            print("❌ Error loading more activities: \(error)")
        }
        
        isLoadingMore = false
    }
    

    func applyFilters() async {
        var result = allActivities
        
        // Apply radius filter
        if let radiusKm = filter.radiusKm,
           let userLocation = filter.userLocation {
            result = result.filter { activity in
                guard let activityLocation = activity.location else {
                    return false
                }
                let distance = userLocation.distance(to: activityLocation)
                return distance <= radiusKm
            }
        }
        
        // Apply search filter (now only when explicitly set)
        if !filter.searchText.isEmpty {
            let searchLower = filter.searchText.lowercased()
            result = result.filter { activity in
                activity.name.lowercased().contains(searchLower) ||
                (activity.description?.lowercased().contains(searchLower) ?? false) ||
                (activity.location?.name.lowercased().contains(searchLower) ?? false)
            }
        }
        
        filteredActivities = result
        
        print("🔍 Applied filters: \(allActivities.count) → \(filteredActivities.count) activities")
        if !filter.searchText.isEmpty {
            print("   Search term: '\(filter.searchText)'")
        }
    }
    
    func updateRadiusFilter(radiusKm: Double?) {
        filter.radiusKm = radiusKm
    }
    
    func updateDateRangeFilter(dateRange: DateRangeFilter, currentUserId: String) async {
        let previousFilter = filter
        filter.dateRange = dateRange
        
        if previousFilter.dateRange != dateRange {
            await refreshActivities(currentUserId: currentUserId)
        }
    }
    
    func updateUserLocation(_ location: DBLocation) {
        filter.userLocation = location
    }
    
    func clearFilters(currentUserId: String) async {
        filter = ActivityFilter(userLocation: filter.userLocation)
        searchText = "" 
        await refreshActivities(currentUserId: currentUserId)
    }
    
    func refreshActivities(currentUserId: String) async {
        activityManager.resetPagination()
        allActivities = []
        activities = []
        filteredActivities = []
        hasMoreActivities = true
        await loadInitialActivities(currentUserId: currentUserId)
    }
    
    func cancelActivity(activity: Activity, currentUserId: String) async throws {
        try await activityManager.cancelActivity(activity: activity, userId: currentUserId)
        await refreshActivity(activity: activity)
    }
    
    func joinActivity(activity: Activity, currentUserId: String) async throws {
        try await activityManager.joinActivity(activity: activity, userId: currentUserId)
        await refreshActivity(activity: activity)
    }
    
    func refreshActivity(activity: Activity) async {
        do {
            let updated = try await activityManager.refreshActivity(activityId: activity.id)
            
            if let index = allActivities.firstIndex(where: { $0.id == activity.id }) {
                allActivities[index] = updated
            }
            if let index = activities.firstIndex(where: { $0.id == activity.id }) {
                activities[index] = updated
            }
            if let index = filteredActivities.firstIndex(where: { $0.id == activity.id }) {
                filteredActivities[index] = updated
            }
        } catch {
            print("⚠️ Failed to refresh activity: \(error.localizedDescription)")
        }
    }
    
    func stopListening(currentUserId: String) {
        activityManager.stopListeningForActivities()
    }
}
