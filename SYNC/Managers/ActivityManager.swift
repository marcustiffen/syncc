import Combine
import CoreLocation
import Foundation
import FirebaseFirestore

class ActivityManager: ObservableObject {
    private let db = Firestore.firestore()
    
    // Pagination state
    private var lastDocument: DocumentSnapshot?
    private var isLoadingMore = false
    private var hasMoreActivities = true
    
    // Real-time listener
    private var activitiesListener: ListenerRegistration?
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    static let shared = ActivityManager()
    
    
    private func activitiesCollection() -> CollectionReference {
        db.collection("activities")
    }

    
    private func activityDocument(id: String) -> DocumentReference {
        activitiesCollection().document(id)
    }
    
    // MARK: - Create & Delete
    
    func createActivity(userId: String, activity: Activity) async throws {
        try activityDocument(id: activity.id).setData(from: activity, merge: false)
    }
    
    func deleteActivity(userId: String, id: String) async throws {
        try await activityDocument(id: id).delete()
    }
    
    // MARK: - Fetch Initial Activities (Paginated)
    
    /// Fetches the initial batch of activities from the user's matches
    /// - Parameters:
    ///   - currentUserId: The current user's ID
    ///   - matchedUserIds: Array of user IDs that the current user has matched with
    ///   - limit: Number of activities to fetch (default: 10)
    /// - Returns: Array of activities sorted by createdAt descending
    func fetchInitialActivities(currentUserId: String, matchedUserIds: [String], limit: Int = 10) async throws -> [Activity] {
        
        // Reset pagination state
        lastDocument = nil
        hasMoreActivities = true
        
        guard !matchedUserIds.isEmpty else {
            print("No matches found - returning empty array")
            return []
        }
        
        // Firestore 'in' queries support max 10 items, so we need to batch
        let batchedIds = matchedUserIds.chunked(into: 10)
        var allActivities: [Activity] = []
        
        for batch in batchedIds {
            let query = activitiesCollection()
                .whereField("creatorId", in: batch) // ✅ FIXED: Uncommented this line
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            let snapshot = try await query.getDocuments()
            
            let activities = try snapshot.documents.compactMap { document -> Activity? in
                try document.data(as: Activity.self)
            }
            
            allActivities.append(contentsOf: activities)
            
            // Store the last document for pagination
            if let last = snapshot.documents.last {
                lastDocument = last
            }
        }
        
        // Sort all activities by createdAt and take the top 'limit'
        allActivities.sort { $0.createdAt > $1.createdAt }
        let limitedActivities = Array(allActivities.prefix(limit))
        
        // Update hasMoreActivities flag
        hasMoreActivities = allActivities.count >= limit
        
        return limitedActivities
    }
    
    // MARK: - Load More Activities (Infinite Scroll)
    
    /// Loads the next batch of activities for infinite scroll
    /// - Parameters:
    ///   - currentUserId: The current user's ID
    ///   - matchedUserIds: Array of user IDs that the current user has matched with
    ///   - limit: Number of activities to fetch (default: 10)
    /// - Returns: Array of additional activities
    func loadMoreActivities(currentUserId: String, matchedUserIds: [String], limit: Int = 10) async throws -> [Activity] {
        
        // Prevent multiple simultaneous loads
        guard !isLoadingMore else {
            print("Already loading more activities")
            return []
        }
        
        // Check if there are more activities to load
        guard hasMoreActivities else {
            print("No more activities to load")
            return []
        }
        
        // Need a starting point for pagination
        guard let lastDoc = lastDocument else {
            print("No last document - use fetchInitialActivities first")
            return []
        }
        
        guard !matchedUserIds.isEmpty else {
            print("No matches found")
            return []
        }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        // Batch the matched user IDs (max 10 per 'in' query)
        let batchedIds = matchedUserIds.chunked(into: 10)
        var allActivities: [Activity] = []
        
        for batch in batchedIds {
            let query = activitiesCollection()
                .whereField("creatorId", in: batch)
                .order(by: "createdAt", descending: true)
                .start(afterDocument: lastDoc)
                .limit(to: limit)
            
            let snapshot = try await query.getDocuments()
            
            let activities = try snapshot.documents.compactMap { document -> Activity? in
                try document.data(as: Activity.self)
            }
            
            allActivities.append(contentsOf: activities)
            
            // Update last document
            if let last = snapshot.documents.last {
                lastDocument = last
            }
        }
        
        // Sort by createdAt
        allActivities.sort { $0.createdAt > $1.createdAt }
        let limitedActivities = Array(allActivities.prefix(limit))
        
        // Update flag
        hasMoreActivities = !allActivities.isEmpty && allActivities.count >= limit
        
        return limitedActivities
    }
    
    // MARK: - Real-Time Listener for New Activities
    
    /// Sets up a real-time listener for new activities from matches
    /// This will notify when NEW activities are created AFTER the listener is set up
    /// - Parameters:
    ///   - currentUserId: The current user's ID
    ///   - matchedUserIds: Array of user IDs that the current user has matched with
    ///   - onNewActivities: Callback with newly created activities
    func listenForNewActivities(currentUserId: String, matchedUserIds: [String], onNewActivities: @escaping ([Activity]) -> Void) {
        
        // Remove existing listener
        stopListeningForActivities()
        
        guard !matchedUserIds.isEmpty else {
            print("No matches to listen to")
            return
        }
        
        // Only listen to the first batch of 10 (Firestore limitation)
        // For production, you might want a more sophisticated approach
        let limitedMatches = Array(matchedUserIds.prefix(10))
        
        // Listen for activities created in the last minute (to avoid loading all historical data)
        let recentTime = Date().addingTimeInterval(-60) // Last 60 seconds
        
        activitiesListener = activitiesCollection()
            .whereField("creatorId", in: limitedMatches)
            .whereField("createdAt", isGreaterThan: Timestamp(date: recentTime))
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening for activities: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                // Only process new documents (not initial load or modifications)
                let newActivities = snapshot.documentChanges
                    .filter { $0.type == .added }
                    .compactMap { change -> Activity? in
                        try? change.document.data(as: Activity.self)
                    }
                
                if !newActivities.isEmpty {
                    onNewActivities(newActivities)
                }
            }
    }
    
    /// Stops the real-time listener
    func stopListeningForActivities() {
        activitiesListener?.remove()
        activitiesListener = nil
    }
    
    // MARK: - Helper: Get User's Match IDs
    
    /// Fetches all match IDs for a user
    /// IMPORTANT: For better performance, consider storing matchedUserIds as an array field
    /// on the user document instead of querying the matches subcollection
    /// - Parameter userId: The user's ID
    /// - Returns: Array of matched user IDs
    func fetchMatchedUserIds(userId: String) async throws -> [String] {
        let matchesCollection = db.collection("users").document(userId).collection("matches")
        let snapshot = try await matchesCollection.getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
    
    // MARK: - Reset Pagination
    
    /// Resets pagination state (useful when refreshing the feed)
    func resetPagination() {
        lastDocument = nil
        hasMoreActivities = true
        isLoadingMore = false
    }
    
    
    func joinActivity(activity: Activity, userId: String) async throws {
        let mainActivityDocument = db.collection("activities").document(activity.id)
        
        try await mainActivityDocument.updateData([
            "participants": FieldValue.arrayUnion([userId])
        ])
    }
    
    
    func cancelActivity(activity: Activity, userId: String) async throws {
        let mainActivityDocument = db.collection("activities").document(activity.id)
        
        try await mainActivityDocument.updateData([
            "participants": FieldValue.arrayRemove([userId])
        ])
    }
    
    
    func refreshActivity(activityId: String) async throws -> Activity {
        let docRef = db.collection("activities").document(activityId)
        let snapshot = try await docRef.getDocument()
        
        guard let activity = try? snapshot.data(as: Activity.self) else {
            throw URLError(.badServerResponse)
        }
        return activity
    }

}


extension ActivityManager {
    func fetchMyActivities(userId: String, limit: Int = 10) async throws -> [Activity] {
        
        // Reset pagination state
        lastDocument = nil
        hasMoreActivities = true
        
        let query = activitiesCollection()
            .whereField("creatorId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        let snapshot = try await query.getDocuments()
        
        let activities = try snapshot.documents.compactMap { document -> Activity? in
            try document.data(as: Activity.self)
        }
        
        // Store the last document for pagination
        if let last = snapshot.documents.last {
            lastDocument = last
        }
        
        // Update hasMoreActivities flag
        hasMoreActivities = activities.count >= limit
        
        return activities
    }

    
    func loadMoreMyActivities(userId: String, limit: Int = 10) async throws -> [Activity] {
        
        // Prevent multiple simultaneous loads
        guard !isLoadingMore else {
            print("Already loading more activities")
            return []
        }
        
        // Check if there are more activities to load
        guard hasMoreActivities else {
            print("No more activities to load")
            return []
        }
        
        // Need a starting point for pagination
        guard let lastDoc = lastDocument else {
            print("No last document - use fetchMyActivities first")
            return []
        }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        let query = activitiesCollection()
            .whereField("creatorId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDoc)
            .limit(to: limit)
        
        let snapshot = try await query.getDocuments()
        
        let activities = try snapshot.documents.compactMap { document -> Activity? in
            try document.data(as: Activity.self)
        }
        
        // Update last document
        if let last = snapshot.documents.last {
            lastDocument = last
        }
        
        // Update flag
        hasMoreActivities = !activities.isEmpty && activities.count >= limit
        
        return activities
    }

    
    func listenForMyNewActivities(userId: String, onNewActivities: @escaping ([Activity]) -> Void) {
        
        // Remove existing listener
        stopListeningForActivities()
        
        // Listen for activities created in the last minute (to avoid loading all historical data)
        let recentTime = Date().addingTimeInterval(-60) // Last 60 seconds
        
        activitiesListener = activitiesCollection()
            .whereField("creatorId", isEqualTo: userId)
            .whereField("createdAt", isGreaterThan: Timestamp(date: recentTime))
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening for my activities: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                // Only process new documents (not initial load or modifications)
                let newActivities = snapshot.documentChanges
                    .filter { $0.type == .added }
                    .compactMap { change -> Activity? in
                        try? change.document.data(as: Activity.self)
                    }
                
                if !newActivities.isEmpty {
                    onNewActivities(newActivities)
                }
            }
    }
}




extension ActivityManager {
    
    // MARK: - Fetch Initial Activities with Filters
    
    /// Fetches the initial batch of activities with optional date range filtering
    /// - Parameters:
    ///   - currentUserId: The current user's ID
    ///   - matchedUserIds: Array of user IDs that the current user has matched with
    ///   - dateRange: Optional date range filter to apply server-side
    ///   - limit: Number of activities to fetch (default: 20)
    /// - Returns: Array of activities sorted by startTime ascending
    func fetchInitialActivities(
        currentUserId: String,
        matchedUserIds: [String],
        dateRange: DateRangeFilter = .all,
        limit: Int = 20
    ) async throws -> [Activity] {
        
        // Reset pagination state
        lastDocument = nil
        hasMoreActivities = true
        
        guard !matchedUserIds.isEmpty else {
            print("No matches found - returning empty array")
            return []
        }
        
        // ✅ FIXED: Batch the matched user IDs properly
        let batchedIds = matchedUserIds.chunked(into: 10)
        var allActivities: [Activity] = []
        
        for batch in batchedIds {
            var query: Query = activitiesCollection()
                .whereField("creatorId", in: batch) // ✅ Filter by matched users
            
            // Apply date range filter if specified
            if let range = dateRange.dateRange {
                query = query
                    .whereField("startTime", isGreaterThanOrEqualTo: Timestamp(date: range.start))
                    .whereField("startTime", isLessThan: Timestamp(date: range.end))
//                    .order(by: "startTime", descending: false)
                    .order(by: "startTime", descending: true)
            } else {
                query = query.order(by: "createdAt", descending: true)
            }
            
            query = query.limit(to: limit)
            
            let snapshot = try await query.getDocuments()
            
            let activities = try snapshot.documents.compactMap { document -> Activity? in
                try document.data(as: Activity.self)
            }
            
            allActivities.append(contentsOf: activities)
            
            // Store the last document for pagination
            if let last = snapshot.documents.last {
                lastDocument = last
            }
        }
        
        // Sort all activities
        if dateRange.dateRange != nil {
            allActivities.sort { $0.startTime < $1.startTime }
        } else {
            allActivities.sort { $0.createdAt > $1.createdAt }
        }
        
        let limitedActivities = Array(allActivities.prefix(limit))
        
        // Update hasMoreActivities flag
        hasMoreActivities = allActivities.count >= limit
        
        print("📥 Fetched \(limitedActivities.count) activities with date filter: \(dateRange.displayName)")
        
        return limitedActivities
    }
    
    // MARK: - Load More Activities with Filters
    
    /// Loads the next batch of activities with the same filters
    /// - Parameters:
    ///   - currentUserId: The current user's ID
    ///   - matchedUserIds: Array of user IDs that the current user has matched with
    ///   - dateRange: Date range filter to apply server-side
    ///   - limit: Number of activities to fetch (default: 20)
    /// - Returns: Array of additional activities
    func loadMoreActivities(
        currentUserId: String,
        matchedUserIds: [String],
        dateRange: DateRangeFilter = .all,
        limit: Int = 20
    ) async throws -> [Activity] {
        
        // Prevent multiple simultaneous loads
        guard !isLoadingMore else {
            print("Already loading more activities")
            return []
        }
        
        // Check if there are more activities to load
        guard hasMoreActivities else {
            print("No more activities to load")
            return []
        }
        
        // Need a starting point for pagination
        guard let lastDoc = lastDocument else {
            print("No last document - use fetchInitialActivities first")
            return []
        }
        
        guard !matchedUserIds.isEmpty else {
            print("No matches found")
            return []
        }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        // Batch the matched user IDs
        let batchedIds = matchedUserIds.chunked(into: 10)
        var allActivities: [Activity] = []
        
        for batch in batchedIds {
            var query: Query = activitiesCollection()
                .whereField("creatorId", in: batch)
            
            // Apply date range filter if specified
            if let range = dateRange.dateRange {
                query = query
                    .whereField("startTime", isGreaterThanOrEqualTo: Timestamp(date: range.start))
                    .whereField("startTime", isLessThan: Timestamp(date: range.end))
//                    .order(by: "startTime", descending: false)
                    .order(by: "startTime", descending: true)
            } else {
                query = query.order(by: "createdAt", descending: true)
            }
            
            query = query
                .start(afterDocument: lastDoc)
                .limit(to: limit)
            
            let snapshot = try await query.getDocuments()
            
            let activities = try snapshot.documents.compactMap { document -> Activity? in
                try document.data(as: Activity.self)
            }
            
            allActivities.append(contentsOf: activities)
            
            // Update last document
            if let last = snapshot.documents.last {
                lastDocument = last
            }
        }
        
        // Sort activities
        if dateRange.dateRange != nil {
            allActivities.sort { $0.startTime < $1.startTime }
        } else {
            allActivities.sort { $0.createdAt > $1.createdAt }
        }
        
        let limitedActivities = Array(allActivities.prefix(limit))
        
        // Update flag
        hasMoreActivities = !allActivities.isEmpty && allActivities.count >= limit
        
        print("📥 Loaded \(limitedActivities.count) more activities")
        
        return limitedActivities
    }
}
