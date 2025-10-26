import Combine
import CoreLocation
import Foundation
import FirebaseFirestore



//class CompleteUsersModel: ProfileModel {
//    @Published var lastDocumentSnapshot: DocumentSnapshot? = nil
//    @Published var hasMoreUsers = true
//    @Published var isLoadingUsers = false
//    
//    // Separate the raw users from filtered users
//    @Published var allUsers: [DBUser] = []
//    @Published var filteredUsers: [DBUser] = [] // This is what HomeView should use
//    
//    // Exclusion arrays
//    var dismissedUserIds: [String] = []
//    var matchUserIds: [String] = []
//    var likesReceivedUserIds: [String] = []
//    var likesSentUserIds: [String] = []
//    var excludedUserIds: [String] = []
//    
//    // Published collections
//    @Published var matches: [LikeReceived] = [] {
//        didSet { updateUserIds() }
//    }
//    @Published var isNewMatch: Bool = false
//    
//    @Published var likesReceived: [LikeReceived] = [] {
//        didSet { updateUserIds() }
//    }
//    @Published var likesReceivedUsers: [DBUser] = []
//    
//    @Published var likesSent: [LikeReceived] = [] {
//        didSet { updateUserIds() }
//    }
//    
//    @Published var dismissedUsers: [LikeReceived] = [] {
//        didSet { updateUserIds() }
//    }
//    
//    private let db = Firestore.firestore()
//    
//    // Listeners
//    private var usersListener: ListenerRegistration? = nil
//    private var likesReceivedListener: ListenerRegistration? = nil
//    private var likesSentListener: ListenerRegistration? = nil
//    private var matchesListener: ListenerRegistration? = nil
//    private var dismissedUsersListener: ListenerRegistration? = nil
//    
//    // Track loading states
//    private var exclusionsLoaded = false
//    private var usersLoaded = false
//    
//    // Update the user IDs whenever matches, likesReceived, or likesSent change
//    private func updateUserIds() {
//        dismissedUserIds = dismissedUsers.map { $0.userId }
//        matchUserIds = matches.map { $0.userId }
//        likesReceivedUserIds = likesReceived.map { $0.userId }
//        likesSentUserIds = likesSent.map { $0.userId }
//        excludedUserIds = Array(Set(matchUserIds + likesSentUserIds + dismissedUserIds))
//        
//        // Recompute filtered users whenever exclusions change
//        updateFilteredUsers()
//    }
//    
//    private func updateFilteredUsers() {
//        let newFilteredUsers = allUsers.filter { !excludedUserIds.contains($0.uid) }
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.filteredUsers = newFilteredUsers
//        }
//    }
//    
//    // MARK: - Main Setup Method
//    
//    /// Call this method to set up all listeners for a user
//    func setupAllListeners(currentUser: DBUser) {
//        print("Setting up all listeners for user: \(currentUser.uid)")
//        
//        // Reset loading states
//        exclusionsLoaded = false
//        usersLoaded = false
//        isLoadingUsers = true
//        
//        // Start both listeners simultaneously
//        listenForExclusions(userId: currentUser.uid)
//        listenForFilteredUsers(currentUser: currentUser)
//    }
//    
//    // MARK: - Collection References
//    
//    private func usersCollection() -> CollectionReference {
//        db.collection("users")
//    }
//    
//    private func likesReceivedCollection(userId: String) -> CollectionReference {
//        db.collection("users").document(userId).collection("likes_received")
//    }
//    
//    private func likesSentCollection(userId: String) -> CollectionReference {
//        db.collection("users").document(userId).collection("likes_sent")
//    }
//    
//    private func matchesCollection(userId: String) -> CollectionReference {
//        db.collection("users").document(userId).collection("matches")
//    }
//    
//    private func dismissedUsersCollection(userId: String) -> CollectionReference {
//        db.collection("users").document(userId).collection("dismissed_users")
//    }
//    
//    // MARK: - Listener Management
//    
//    func removeAllListeners() {
//        print("Removing all listeners")
//        usersListener?.remove()
//        likesReceivedListener?.remove()
//        likesSentListener?.remove()
//        matchesListener?.remove()
//        dismissedUsersListener?.remove()
//        
//        usersListener = nil
//        likesReceivedListener = nil
//        likesSentListener = nil
//        matchesListener = nil
//        dismissedUsersListener = nil
//        
//        exclusionsLoaded = false
//        usersLoaded = false
//    }
//    
//    // MARK: - Filtered Users Listener
//    
//    func listenForFilteredUsers(currentUser: DBUser) {
//        print("Starting filtered users listener")
//        
//        // Remove previous listener
//        usersListener?.remove()
//        usersListener = nil
//        
//        // Build Firestore query with filters
//        let query = buildUserQuery(currentUser: currentUser)
//        
//        // Attach new listener
//        usersListener = query.addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self else { return }
//            
//            if let error = error {
//                print("Error fetching users: \(error)")
//                DispatchQueue.main.async {
//                    self.isLoadingUsers = false
//                }
//                return
//            }
//            
//            guard let documents = snapshot?.documents else {
//                DispatchQueue.main.async {
//                    self.isLoadingUsers = false
//                }
//                return
//            }
//            
//            print("Received \(documents.count) users from Firestore")
//            
//            // Parse users from Firestore
//            let firestoreUsers = documents.compactMap { try? $0.data(as: DBUser.self) }
//            
//            // Apply location filtering client-side
//            let locationFilteredUsers = self.applyLocationFilter(users: firestoreUsers, currentUser: currentUser)
//            
//            print("After location filtering: \(locationFilteredUsers.count) users")
//            
//            DispatchQueue.main.async {
//                self.allUsers = locationFilteredUsers
//                self.usersLoaded = true
//                self.updateFilteredUsers() // This will apply exclusions
//                self.checkIfLoadingComplete()
//            }
//        }
//    }
//    
//    // MARK: - Exclusions Listener
//    
//    func listenForExclusions(userId: String) {
//        print("Starting exclusions listeners")
//        
//        // Remove previous listeners
//        likesSentListener?.remove()
//        dismissedUsersListener?.remove()
//        matchesListener?.remove()
//        likesReceivedListener?.remove()
//        
//        var exclusionLoadCount = 0
//        let totalExclusionListeners = 4
//        
//        func checkExclusionsLoaded() {
//            exclusionLoadCount += 1
//            if exclusionLoadCount >= totalExclusionListeners {
//                exclusionsLoaded = true
//                checkIfLoadingComplete()
//            }
//        }
//        
//        // likes_sent
//        likesSentListener = likesSentCollection(userId: userId).addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error fetching likes sent: \(error)")
//                return
//            }
//            
//            let likes = snapshot?.documents.compactMap { try? $0.data(as: LikeReceived.self) } ?? []
//            DispatchQueue.main.async {
//                self.likesSent = likes
//                checkExclusionsLoaded()
//            }
//        }
//        
//        // dismissed_users
//        dismissedUsersListener = dismissedUsersCollection(userId: userId).addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error fetching dismissed users: \(error)")
//                return
//            }
//            
//            let dismissed = snapshot?.documents.compactMap { try? $0.data(as: LikeReceived.self) } ?? []
//            DispatchQueue.main.async {
//                self.dismissedUsers = dismissed
//                checkExclusionsLoaded()
//            }
//        }
//        
//        // matches
//        matchesListener = matchesCollection(userId: userId).addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error fetching matches: \(error)")
//                return
//            }
//            
//            let matches = snapshot?.documents.compactMap { try? $0.data(as: LikeReceived.self) } ?? []
//            DispatchQueue.main.async {
//                self.matches = matches
//                checkExclusionsLoaded()
//            }
//        }
//        
//        // likes_received
//        likesReceivedListener = likesReceivedCollection(userId: userId).addSnapshotListener { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error fetching likes received: \(error)")
//                return
//            }
//            
//            let likes = snapshot?.documents.compactMap { try? $0.data(as: LikeReceived.self) } ?? []
//            DispatchQueue.main.async {
//                self.likesReceived = likes
//                checkExclusionsLoaded()
//            }
//        }
//    }
//    
//    private func checkIfLoadingComplete() {
//        if exclusionsLoaded && usersLoaded {
//            print("All data loaded. Final filtered users count: \(filteredUsers.count)")
//            isLoadingUsers = false
//        }
//    }
//    
//    // MARK: - Query Building
//    
//    func buildUserQuery(currentUser: DBUser) -> Query {
//        var query: Query = usersCollection().whereField("uid", isNotEqualTo: currentUser.uid)
//        
//        // Sex filter
//        if let sex = currentUser.filteredSex, sex != "Both" {
//            query = query.whereField("sex", isEqualTo: sex)
//        }
//        
////        // Age filter - UNCOMMENTED and FIXED
//        if let ageRange = currentUser.filteredAgeRange {
//            let calendar = Calendar.current
//            let now = Date()
//            
//            let maxAge = ageRange.max
//            // For max age: user must be born AFTER this date (younger than max age)
//            if let minBirthDate = calendar.date(byAdding: .year, value: -maxAge, to: now) {
//                query = query.whereField("dateOfBirth", isGreaterThanOrEqualTo: minBirthDate)
//            }
//            
//            
//            let minAge = ageRange.min
//            // For min age: user must be born BEFORE this date (older than min age)
//            if let maxBirthDate = calendar.date(byAdding: .year, value: -minAge, to: now) {
//                query = query.whereField("dateOfBirth", isLessThanOrEqualTo: maxBirthDate)
//            }
//        }
////        
////        // Fitness Level filter - UNCOMMENTED
//        if let level = currentUser.filteredFitnessLevel, !level.isEmpty, level != "Any" {
//            query = query.whereField("fitnessLevel", isEqualTo: level)
//        }
//        
//        // NOTE: Fitness Types and Goals filters are commented out because
//        // Firestore has limitations on compound queries. You can only use one
//        // arrayContainsAny per query. If you need both, you'll need to choose
//        // one for Firestore filtering and do the other client-side.
//        
//        /*
//        // Fitness Types filter (arrayContainsAny, max 10 values)
//        if let types = currentUser.filteredFitnessTypes, !types.isEmpty {
//            let typeStrings = types.map { $0.rawValue } // Adjust based on your FitnessType implementation
//            query = query.whereField("fitnessTypes", arrayContainsAny: Array(typeStrings.prefix(10)))
//        }
//        
//        // Fitness Goals filter (arrayContainsAny, max 10 values)
//        if let goals = currentUser.filteredFitnessGoals, !goals.isEmpty {
//            let goalStrings = goals.map { $0.rawValue } // Adjust based on your FitnessGoal implementation
//            query = query.whereField("fitnessGoals", arrayContainsAny: Array(goalStrings.prefix(10)))
//        }
//        */
//        
//        return query
//    }
//    
//    // MARK: - Location Filtering
//    
//    private func applyLocationFilter(users: [DBUser], currentUser: DBUser) -> [DBUser] {
//        guard let currentUserLocation = currentUser.location,
//              let matchRadius = currentUser.filteredMatchRadius else {
//            print("No location or radius filter, returning all users")
//            return users
//        }
//        
//        let filtered = users.filter { user in
//            guard let userLocation = user.location else { return false }
//            let distance = currentUserLocation.location.distance(to: userLocation.location)
//            return distance <= Double(matchRadius * 1000) // Convert km to meters if needed
//        }
//        
//        print("Location filter: \(users.count) -> \(filtered.count) users (radius: \(matchRadius))")
//        return filtered
//    }
//    
//    // MARK: - Legacy Methods (keep for compatibility)
//    
//    func loadUsersForLikesReceived() async throws {
//        let users: [DBUser] = try await withThrowingTaskGroup(of: DBUser.self) { group in
//            for like in likesReceived {
//                group.addTask {
//                    try await DBUserManager.shared.getUser(uid: like.userId)
//                }
//            }
//            
//            var results: [DBUser] = []
//            for try await user in group {
//                results.append(user)
//            }
//            return results
//        }
//        
//        await MainActor.run {
//            self.likesReceivedUsers = users
//        }
//    }
//}
