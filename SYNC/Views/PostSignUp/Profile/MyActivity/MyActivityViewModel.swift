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
    
    
    func updateAndRefreshActivity(activity: Activity, currentUserId: String) async throws {
        // Update in Firestore
        try await activityManager.updateActivity(activity: activity)
        
        // Refresh the activity from Firestore to ensure we have the latest data
        let refreshedActivity = try await activityManager.refreshActivity(activityId: activity.id)
        
        // Update the local array
        if let index = activities.firstIndex(where: { $0.id == activity.id }) {
            activities[index] = refreshedActivity
        }
    }
}
