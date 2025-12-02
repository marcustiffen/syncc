//import Combine
//import CoreLocation
//import Foundation
//import FirebaseFirestore
//
//class DiscoverViewModel: ObservableObject {
//    @Published var userQueue: [DBUser] = []
//    @Published var isLoading = false
//    @Published var isPaginating = false
//    @Published var showPayWall = false
//    @Published var errorMessage: String?
//    
//    private let usersManager = UsersManager()
//    private let matchMakingManager = MatchMakingManager()
//    private var lastFilterHash: Int = 0
//    private var currentUser: DBUser?
//    private var hasInitialized = false
//    
//    // Pagination threshold - load more when user scrolls to this many items from the end
//    private let paginationThreshold = 6
//    
//    // MARK: - Initial Load
//    
//    func loadInitialUsers(for user: DBUser) {
//        currentUser = user
//        lastFilterHash = calculateFilterHash(for: user)
//        userQueue = []
//        usersManager.resetPagination()
//        hasInitialized = true
//        fetchNextPage(for: user, isInitialLoad: true)
//    }
//    
//    // MARK: - Fetch Users
//    
//    func fetchNextPage(for user: DBUser, isInitialLoad: Bool) {
//        guard !isPaginating else {
//            print("Already paginating, skipping fetch")
//            return
//        }
//        
//        isPaginating = true
//        
//        // Only show loading spinner on initial load
//        if isInitialLoad {
//            isLoading = true
//        }
//        
//        // Fetch size: 20 for initial load, 10 for pagination
//        let fetchSize = isInitialLoad ? 20 : 10
//        
//        usersManager.fetchUsers(for: user, pageSize: fetchSize, reset: isInitialLoad) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                self?.isPaginating = false
//                
//                switch result {
//                case .success(let users):
//                    print("✅ Fetched \(users.count) users (initial: \(isInitialLoad))")
//                    
//                    if isInitialLoad {
//                        self?.userQueue = users
//                    } else {
//                        // Filter out duplicates
//                        let newUsers = users.filter { newUser in
//                            !(self?.userQueue.contains { $0.uid == newUser.uid } ?? false)
//                        }
//                        self?.userQueue.append(contentsOf: newUsers)
//                        print("✅ Added \(newUsers.count) new users to queue")
//                    }
//                    
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                    print("❌ Error fetching users: \(error)")
//                }
//            }
//        }
//    }
//    
//    // MARK: - Pagination Logic
//    
//    func shouldLoadMore(currentUser: DBUser) -> Bool {
//        guard let index = userQueue.firstIndex(where: { $0.uid == currentUser.uid }) else {
//            return false
//        }
//        
//        // Load more when we're within paginationThreshold items from the end
//        let shouldLoad = index >= userQueue.count - paginationThreshold
//        
//        if shouldLoad && !isPaginating {
//            print("📊 Should load more: index \(index) of \(userQueue.count)")
//        }
//        
//        return shouldLoad && !isPaginating
//    }
//    
//    
//    func performLike(user: DBUser, currentUser: DBUser, isSubscriptionActive: Bool) {
//        // Check daily like limit
//        if !isSubscriptionActive && (currentUser.dailyLikes ?? 0) < 0 {
//            showPayWall = true
//            return
//        }
//        
//        // Remove from queue immediately for better UX
//        userQueue.removeAll { $0.uid == user.uid }
//        
//        // Send like asynchronously
//        Task.detached { [weak self] in
//            await withCheckedContinuation { continuation in
//                self?.matchMakingManager.sendLike(
//                    currentUserId: currentUser.uid,
//                    likedUserId: user.uid,
//                    isSubscriptionActive: isSubscriptionActive
//                ) { _ in continuation.resume() }
//            }
//        }
//    }
//    
//    func performDislike(user: DBUser, currentUser: DBUser) {
//        // Remove from queue immediately
//        userQueue.removeAll { $0.uid == user.uid }
//        
//        // Send dislike asynchronously
//        Task { [weak self] in
//            await self?.matchMakingManager.dismissUser(
//                currentUserId: currentUser.uid,
//                dismissedUserId: user.uid
//            )
//        }
//    }
//    
//    // MARK: - Filter Management
//    
//    func checkFiltersAndReloadIfNeeded(for user: DBUser) {
//        guard hasInitialized else {
//            print("Not initialized yet, skipping filter check")
//            return
//        }
//        
//        let newFilterHash = calculateFilterHash(for: user)
//        if newFilterHash != lastFilterHash {
//            print("🔄 Filters changed, reloading users")
//            loadInitialUsers(for: user)
//        } else {
//            print("✓ Filters unchanged")
//        }
//    }
//    
//    func refreshUsers(for user: DBUser) {
//        print("🔄 Refreshing users...")
//        loadInitialUsers(for: user)
//    }
//    
//    private func calculateFilterHash(for user: DBUser) -> Int {
//        var hasher = Hasher()
//        hasher.combine(user.filteredSex)
//        hasher.combine(user.filteredAgeRange?.min)
//        hasher.combine(user.filteredAgeRange?.max)
//        hasher.combine(user.filteredMatchRadius)
//        hasher.combine(user.filteredFitnessLevel)
//        hasher.combine(user.filteredFitnessTypes)
//        hasher.combine(user.filteredFitnessGoals)
//        hasher.combine(user.blockedSex)
//        return hasher.finalize()
//    }
//}




import Combine
import CoreLocation
import Foundation
import FirebaseFirestore

class DiscoverViewModel: ObservableObject {
    @Published var userQueue: [DBUser] = []
    @Published var isLoading = false
    @Published var isPaginating = false
    @Published var showPayWall = false
    @Published var errorMessage: String?
    
    private let usersManager = UsersManager()
    private let matchMakingManager = MatchMakingManager()
    private var lastFilterHash: Int = 0
    private var currentUser: DBUser?
    private var hasInitialized = false
    
    // Pagination threshold - load more when user scrolls to this many items from the end
    private let paginationThreshold = 6
    
    // MARK: - Initial Load
    
    func loadInitialUsers(for user: DBUser) {
        currentUser = user
        lastFilterHash = calculateFilterHash(for: user)
        userQueue = []
        usersManager.resetPagination()
        hasInitialized = true
        fetchNextPage(for: user, isInitialLoad: true)
    }
    
    // MARK: - Fetch Users
    
    func fetchNextPage(for user: DBUser, isInitialLoad: Bool) {
        guard !isPaginating else {
            print("Already paginating, skipping fetch")
            return
        }
        
        isPaginating = true
        
        // Only show loading spinner on initial load
        if isInitialLoad {
            isLoading = true
        }
        
        // Fetch size: 20 for initial load, 10 for pagination
        let fetchSize = isInitialLoad ? 20 : 10
        
        usersManager.fetchUsers(for: user, pageSize: fetchSize, reset: isInitialLoad) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isPaginating = false
                
                switch result {
                case .success(let users):
                    print("✅ Fetched \(users.count) users (initial: \(isInitialLoad))")
                    
                    if isInitialLoad {
                        self?.userQueue = users
                    } else {
                        // Filter out duplicates
                        let newUsers = users.filter { newUser in
                            !(self?.userQueue.contains { $0.uid == newUser.uid } ?? false)
                        }
                        self?.userQueue.append(contentsOf: newUsers)
                        print("✅ Added \(newUsers.count) new users to queue")
                    }
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error fetching users: \(error)")
                }
            }
        }
    }
    
    // MARK: - Pagination Logic
    
    func shouldLoadMore(currentUser: DBUser) -> Bool {
        guard let index = userQueue.firstIndex(where: { $0.uid == currentUser.uid }) else {
            return false
        }
        
        // Load more when we're within paginationThreshold items from the end
        let shouldLoad = index >= userQueue.count - paginationThreshold
        
        if shouldLoad && !isPaginating {
            print("📊 Should load more: index \(index) of \(userQueue.count)")
        }
        
        return shouldLoad && !isPaginating
    }
    
    
    func performLike(user: DBUser, currentUser: DBUser, isSubscriptionActive: Bool, completion: @escaping (Bool) -> Void) {
        // Check daily like limit
        if !isSubscriptionActive && (currentUser.dailyLikes ?? 0) <= 0 {
            showPayWall = true
            completion(false) // Like was NOT successful
            return
        }
        
        // Remove from queue immediately for better UX
        userQueue.removeAll { $0.uid == user.uid }
        
        // Send like asynchronously
        Task.detached { [weak self] in
            await withCheckedContinuation { continuation in
                self?.matchMakingManager.sendLike(
                    currentUserId: currentUser.uid,
                    likedUserId: user.uid,
                    isSubscriptionActive: isSubscriptionActive
                ) { _ in
                    continuation.resume()
                }
            }
            
            // Call completion on main thread after like is sent
            await MainActor.run {
                completion(true) // Like was successful
            }
        }
    }
    
    func performDislike(user: DBUser, currentUser: DBUser) {
        // Remove from queue immediately
        userQueue.removeAll { $0.uid == user.uid }
        
        // Send dislike asynchronously
        Task { [weak self] in
            await self?.matchMakingManager.dismissUser(
                currentUserId: currentUser.uid,
                dismissedUserId: user.uid
            )
        }
    }
    
    // MARK: - Filter Management
    
    func checkFiltersAndReloadIfNeeded(for user: DBUser) {
        guard hasInitialized else {
            print("Not initialized yet, skipping filter check")
            return
        }
        
        let newFilterHash = calculateFilterHash(for: user)
        if newFilterHash != lastFilterHash {
            print("🔄 Filters changed, reloading users")
            loadInitialUsers(for: user)
        } else {
            print("✓ Filters unchanged")
        }
    }
    
    func refreshUsers(for user: DBUser) {
        print("🔄 Refreshing users...")
        loadInitialUsers(for: user)
    }
    
    private func calculateFilterHash(for user: DBUser) -> Int {
        var hasher = Hasher()
        hasher.combine(user.filteredSex)
        hasher.combine(user.filteredAgeRange?.min)
        hasher.combine(user.filteredAgeRange?.max)
        hasher.combine(user.filteredMatchRadius)
        hasher.combine(user.filteredFitnessLevel)
        hasher.combine(user.filteredFitnessTypes)
        hasher.combine(user.filteredFitnessGoals)
        hasher.combine(user.blockedSex)
        return hasher.finalize()
    }
}
