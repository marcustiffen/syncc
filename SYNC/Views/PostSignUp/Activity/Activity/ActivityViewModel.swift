import SwiftUI

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMoreActivities = true
    
    private let activityManager = ActivityManager.shared
    private var matchedUserIds: [String] = []
    
    
    func loadInitialActivities(currentUserId: String) async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // First, fetch the user's match IDs
            // OPTIMIZATION: Cache this or store as array field on user document
            matchedUserIds = try await activityManager.fetchMatchedUserIds(userId: currentUserId)
            
            guard !matchedUserIds.isEmpty else {
                activities = []
                isLoading = false
                return
            }
            
            // Fetch initial activities
            let fetchedActivities = try await activityManager.fetchInitialActivities(
                currentUserId: currentUserId,
                matchedUserIds: matchedUserIds,
                limit: 10
            )
            print("\(fetchedActivities.count) initial activities loaded")
            
            activities = fetchedActivities
            
            
        } catch {
            errorMessage = "Failed to load activities: \(error.localizedDescription)"
            print("Error loading activities: \(error)")
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
                limit: 10
            )
            
            // Append new activities, avoiding duplicates
            let newActivities = moreActivities.filter { newActivity in
                !activities.contains { $0.id == newActivity.id }
            }
            
            activities.append(contentsOf: newActivities)
            
            // Update flag based on whether we got results
            hasMoreActivities = !moreActivities.isEmpty
            
        } catch {
            errorMessage = "Failed to load more activities: \(error.localizedDescription)"
            print("Error loading more activities: \(error)")
        }
        
        isLoadingMore = false
    }
    
    
    private func startListeningForNewActivities(currentUserId: String) {
        activityManager.listenForNewActivities(
            currentUserId: currentUserId,
            matchedUserIds: matchedUserIds
        ) { [weak self] newActivities in
            guard let self = self else { return }
            
            // Prepend new activities to the top of the feed
            for newActivity in newActivities.reversed() {
                // Avoid duplicates
                if !self.activities.contains(where: { $0.id == newActivity.id }) {
                    self.activities.insert(newActivity, at: 0)
                }
            }
        }
    }
    
    
    func refreshActivities(currentUserId: String) async {
        activityManager.resetPagination()
        await loadInitialActivities(currentUserId: currentUserId)
    }
    
    
    func cancelActivity(activity: Activity, currentUserId: String) async throws {
        try await activityManager.cancelActivity(activity: activity, userId: currentUserId)
    }
    
    
    func refreshActivity(activity: Activity) async {
        do {
            let updated = try await activityManager.refreshActivity(activityId: activity.id)
            
            if let index = activities.firstIndex(where: { $0.id == activity.id }) {
                activities[index] = updated
            }
        } catch {
            print("⚠️ Failed to refresh activity: \(error.localizedDescription)")
        }
    }
    
    
    
    func stopListening(currentUserId: String) {
        activityManager.stopListeningForActivities()
    }
    
    
    func joinActivity(activity: Activity, currentUserId: String) async throws {
        try await activityManager.joinActivity(activity: activity, userId: currentUserId)
    }
}
