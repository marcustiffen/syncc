import Combine
import CoreLocation
import Foundation
import FirebaseFirestore



class UsersManager: ObservableObject {
    
    private let db = Firestore.firestore()
    
    private var lastDocument: DocumentSnapshot?
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    private var usersListener: ListenerRegistration?
    
    private func usersCollection() -> CollectionReference {
        db.collection("users")
    }
    
    private func userDocument(uid: String) -> DocumentReference {
        usersCollection().document(uid)
    }
    
    private var likesReceivedListener: ListenerRegistration?
    
    private func likesReceivedCollection(userId: String) -> CollectionReference {
        userDocument(uid: userId).collection("likes_received")
    }
    
    private func likesSentCollection(userId: String) -> CollectionReference {
        userDocument(uid: userId).collection("likes_sent")
    }
    
    private func matchesCollection(userId: String) -> CollectionReference {
        userDocument(uid: userId).collection("matches")
    }
    
    private func dismissedUsersCollection(userId: String) -> CollectionReference {
        userDocument(uid: userId).collection("dismissed_users")
    }
    
    func getFilteredUsers(for currentUser: DBUser) -> AnyPublisher<[DBUser], Error> {
        // First get all users matching the basic filters
        let query = buildBaseQuery(for: currentUser)
        
        return query.addSnapShotListener(as: DBUser.self)
            .0 // Get the publisher from the tuple
            .flatMap { [weak self] users in
                self?.filterOutInteractedUsers(users: users, currentUserId: currentUser.uid) ??
                Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .map { [weak self] users in
                self?.applyClientSideFilters(users: users, currentUser: currentUser) ?? []
            }
            .eraseToAnyPublisher()
    }
    
    
    
    func fetchUsers(for currentUser: DBUser, pageSize: Int = 7, reset: Bool = false, completion: @escaping (Result<[DBUser], Error>) -> Void) {
        if reset { lastDocument = nil }
        
        // Use adaptive pagination to ensure we get enough users after filtering
        fetchUsersWithAdaptivePagination(currentUser: currentUser, targetCount: pageSize, reset: reset, completion: completion)
    }
    
    private func fetchUsersWithAdaptivePagination(currentUser: DBUser, targetCount: Int, reset: Bool, completion: @escaping (Result<[DBUser], Error>) -> Void) {
        if reset { lastDocument = nil }
        
        fetchUsersWithAdaptivePaginationRecursive(currentUser: currentUser, targetCount: targetCount, reset: reset, attempts: 0, completion: completion)
    }
    
    private func fetchUsersWithAdaptivePaginationRecursive(currentUser: DBUser, targetCount: Int, reset: Bool, attempts: Int, completion: @escaping (Result<[DBUser], Error>) -> Void) {
        // Safety check to prevent infinite loops
        if attempts > 3 {
            print("Too many fetch attempts, returning what we have")
            completion(.success([]))
            return
        }
        
        var query: Query = db.collection("users")
            .whereField("uid", isNotEqualTo: currentUser.uid)
        
        // Completed Users
        query = query.whereField("onboardingStep", isEqualTo: "complete")
        
        // Server-side filters
        if let sex = currentUser.filteredSex, sex != "Both" {
            query = query.whereField("sex", isEqualTo: sex)
        }
        if let ageRange = currentUser.filteredAgeRange {
            let calendar = Calendar.current
            let now = Date()
            let maxAge = ageRange.max
            if let minBirthDate = calendar.date(byAdding: .year, value: -maxAge, to: now) {
                query = query.whereField("dateOfBirth", isGreaterThanOrEqualTo: minBirthDate)
            }
            let minAge = ageRange.min
            if let maxBirthDate = calendar.date(byAdding: .year, value: -minAge, to: now) {
                query = query.whereField("dateOfBirth", isLessThanOrEqualTo: maxBirthDate)
            }
        }
        if let level = currentUser.filteredFitnessLevel, !level.isEmpty, level != "Any" {
            query = query.whereField("fitnessLevel", isEqualTo: level)
        }
//        if let filteredGoals = currentUser.filteredFitnessGoals, !filteredGoals.isEmpty {
//            query = query.whereField("fitnessGoals", arrayContainsAny: filteredGoals)
//        }
        if let filteredTypes = currentUser.filteredFitnessTypes, !filteredTypes.isEmpty {
            query = query.whereField("fitnessTypes", arrayContainsAny: filteredTypes)
        }
        
        // Use a larger page size to account for filtering, but never exceed 10
        let fetchSize = min(max(targetCount * 2, targetCount + 3), 10) // Fetch more to account for filtering, max 10
        query = query.limit(to: fetchSize)
        
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let self = self, let snapshot = snapshot else {
                completion(.success([]))
                return
            }
            
            let users = snapshot.documents.compactMap { try? $0.data(as: DBUser.self) }
            
            print("Fetched \(users.count) users from Firestore (attempt \(attempts + 1))")
            
            // Update lastDocument for pagination
            self.lastDocument = snapshot.documents.last
            
            // Now filter out users in likes_sent, matches, dismissed_users
            self.getExcludedUserIds(currentUserId: currentUser.uid) { excludedIdsResult in
                switch excludedIdsResult {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let excludedIds):
                    let filtered = self.applyClientSideDistanceFilter(users: users, currentUser: currentUser)
                        .filter { !excludedIds.contains($0.uid) }
                    
                    print("After filtering: \(filtered.count) users available (excluded \(excludedIds.count) users)")
                    
                    // If we don't have enough users and there are more documents, fetch more
                    if filtered.count < targetCount && !snapshot.documents.isEmpty && snapshot.documents.count >= fetchSize {
                        print("Only got \(filtered.count) users after filtering, need \(targetCount). Fetching more... (attempt \(attempts + 1))")
                        self.fetchUsersWithAdaptivePaginationRecursive(currentUser: currentUser, targetCount: targetCount, reset: false, attempts: attempts + 1, completion: completion)
                    } else {
                        // Return what we have (either enough users or no more available)
                        print("Returning \(filtered.count) users (target was \(targetCount))")
                        completion(.success(filtered))
                    }
                }
            }
        }
    }
    
    // Get all user IDs from likes_sent, matches, and dismissed_users
    private func getExcludedUserIds(currentUserId: String, completion: @escaping (Result<Set<String>, Error>) -> Void) {
        let group = DispatchGroup()
        var likedUserIds: Set<String> = []
        var matchedUserIds: Set<String> = []
        var dismissedUserIds: Set<String> = []
        var fetchError: Error?
        
        group.enter()
        db.collection("users").document(currentUserId).collection("likes_sent").getDocuments { snapshot, error in
            if let error = error { fetchError = error }
            likedUserIds = Set(snapshot?.documents.map { $0.documentID } ?? [])
            group.leave()
        }
        group.enter()
        db.collection("users").document(currentUserId).collection("matches").getDocuments { snapshot, error in
            if let error = error { fetchError = error }
            matchedUserIds = Set(snapshot?.documents.map { $0.documentID } ?? [])
            group.leave()
        }
        group.enter()
        db.collection("users").document(currentUserId).collection("dismissed_users").getDocuments { snapshot, error in
            if let error = error { fetchError = error }
            dismissedUserIds = Set(snapshot?.documents.map { $0.documentID } ?? [])
            group.leave()
        }
        
        group.notify(queue: .main) {
            if let error = fetchError {
                completion(.failure(error))
            } else {
                let excluded = likedUserIds.union(matchedUserIds).union(dismissedUserIds)
                completion(.success(excluded))
            }
        }
    }
    
    // Only filter by distance in Swift if you must
    private func applyClientSideDistanceFilter(users: [DBUser], currentUser: DBUser) -> [DBUser] {
        guard let radius = currentUser.filteredMatchRadius,
              let currentLocation = currentUser.location else { return users }
        let currentGeoPoint = GeoPoint(latitude: currentLocation.location.latitude, longitude: currentLocation.location.longitude)
        return users.filter { user in
            guard let userLocation = user.location else { return false }
            let userGeoPoint = GeoPoint(latitude: userLocation.location.latitude, longitude: userLocation.location.longitude)
            let distance = calculateDistance(from: currentGeoPoint, to: userGeoPoint)
            return distance <= Double(radius)
        }
    }
    
    
    func resetPagination() {
        lastDocument = nil
    }
    
    
    func addListenerForLikesReceived(userId: String) -> AnyPublisher<[LikeReceived], Error> {
        let (publisher, listener) = likesReceivedCollection(userId: userId)
            .order(by: "timestamp", descending: true)
            .addSnapShotListener(as: LikeReceived.self)
        self.likesReceivedListener = listener
        return publisher
    }
    
    
    private func buildBaseQuery(for currentUser: DBUser) -> Query {
        var query: Query = usersCollection()
            .whereField("uid", isNotEqualTo: currentUser.uid)
        
        // Sex filter
        if let sex = currentUser.filteredSex, sex != "Both" {
            query = query.whereField("sex", isEqualTo: sex)
        }
        
        
        // Age filter
        if let ageRange = currentUser.filteredAgeRange {
            let calendar = Calendar.current
            let now = Date()
            
            let maxAge = ageRange.max
            if let minBirthDate = calendar.date(byAdding: .year, value: -maxAge, to: now) {
                query = query.whereField("dateOfBirth", isGreaterThanOrEqualTo: minBirthDate)
            }
            
            let minAge = ageRange.min
            if let maxBirthDate = calendar.date(byAdding: .year, value: -minAge, to: now) {
                query = query.whereField("dateOfBirth", isLessThanOrEqualTo: maxBirthDate)
            }
        }
        
        // Fitness level filter
        if let level = currentUser.filteredFitnessLevel, !level.isEmpty, level != "Any" {
            query = query.whereField("fitnessLevel", isEqualTo: level)
        }
        
        return query
    }
    
    private func filterOutInteractedUsers(users: [DBUser], currentUserId: String) -> AnyPublisher<[DBUser], Error> {
        let group = DispatchGroup()
        var likedUserIds: Set<String> = []
        var matchedUserIds: Set<String> = []
        var dismissedUserIds: Set<String> = []
        var hasError = false
        
        // Get liked users
        group.enter()
        likesSentCollection(userId: currentUserId).getDocuments { snapshot, error in
            defer { group.leave() }
            if error != nil {
                hasError = true
                return
            }
            likedUserIds = Set(snapshot?.documents.compactMap { $0.documentID } ?? [])
        }
        
        // Get matched users
        group.enter()
        matchesCollection(userId: currentUserId).getDocuments { snapshot, error in
            defer { group.leave() }
            if error != nil {
                hasError = true
                return
            }
            matchedUserIds = Set(snapshot?.documents.compactMap { $0.documentID } ?? [])
        }
        
        // Get dismissed users
        group.enter()
        dismissedUsersCollection(userId: currentUserId).getDocuments { snapshot, error in
            defer { group.leave() }
            if error != nil {
                hasError = true
                return
            }
            dismissedUserIds = Set(snapshot?.documents.compactMap { $0.documentID } ?? [])
        }
        
        return Future<[DBUser], Error> { promise in
            group.notify(queue: .main) {
                if hasError {
                    promise(.failure(NSError(domain: "UsersManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch user interactions"])))
                    return
                }
                
                let excludedUserIds = likedUserIds.union(matchedUserIds).union(dismissedUserIds)
                let filteredUsers = users.filter { !excludedUserIds.contains($0.uid) }
                promise(.success(filteredUsers))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func applyClientSideFilters(users: [DBUser], currentUser: DBUser) -> [DBUser] {
        var filteredUsers = users
        
        if let currentUserSex = currentUser.sex {
            filteredUsers = filteredUsers.filter { user in
                guard let userBlockedSex = user.blockedSex else { return true }
                // Keep the user if they haven't blocked the current user's sex OR if they have "None" as blocked
                return userBlockedSex != currentUserSex || userBlockedSex == "None"
            }
        }
        
        // Location filter
        if let radius = currentUser.filteredMatchRadius,
           let currentLocation = currentUser.location {
            
            // Convert DBLocation to GeoPoint
            let currentGeoPoint = GeoPoint(latitude: currentLocation.location.latitude, longitude: currentLocation.location.longitude)
            
            filteredUsers = filteredUsers.filter { user in
                guard let userLocation = user.location else { return false }
                
                // Convert user location to GeoPoint
                let userGeoPoint = GeoPoint(latitude: userLocation.location.latitude, longitude: userLocation.location.longitude)
                
                let distance = calculateDistance(
                    from: currentGeoPoint,
                    to: userGeoPoint
                )
                return distance <= Double(radius)
            }
        }
        
        
        // Fitness types filter
        if let filteredTypes = currentUser.filteredFitnessTypes,
           !filteredTypes.isEmpty {
            filteredUsers = filteredUsers.filter { user in
                guard let userTypes = user.fitnessTypes else { return false }
                return !Set(filteredTypes.map { $0.id }).isDisjoint(with: Set(userTypes.map { $0.id }))
            }
        }
        
        // Fitness goals filter
        if let filteredGoals = currentUser.filteredFitnessGoals,
           !filteredGoals.isEmpty {
            filteredUsers = filteredUsers.filter { user in
                guard let userGoals = user.fitnessGoals else { return false }
                return !Set(filteredGoals.map { $0.id }).isDisjoint(with: Set(userGoals.map { $0.id }))
            }
        }
        
        return filteredUsers
    }
    
    private func calculateDistance(from location1: GeoPoint, to location2: GeoPoint) -> Double {
        let lat1 = location1.latitude * .pi / 180
        let lon1 = location1.longitude * .pi / 180
        let lat2 = location2.latitude * .pi / 180
        let lon2 = location2.longitude * .pi / 180
        
        let dLat = lat2 - lat1
        let dLon = lon2 - lon1
        
        let a = sin(dLat/2) * sin(dLat/2) + cos(lat1) * cos(lat2) * sin(dLon/2) * sin(dLon/2)
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return 6371 * c // Earth's radius in kilometers
    }
    
    deinit {
        usersListener?.remove()
    }
}
