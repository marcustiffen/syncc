import Combine
import CoreLocation
import Foundation
import FirebaseFirestore

class DiscoverViewModel: ObservableObject {
    @Published var userQueue: [DBUser] = []
    @Published var filteredUserQueue: [DBUser] = []
    @Published var isLoading = false
    @Published var isPaginating = false
    @Published var showPayWall = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var activeSearchText = "" 
    
    private let usersManager = UsersManager()
    private let matchMakingManager = MatchMakingManager()
    private var lastFilterHash: Int = 0
    private var currentUser: DBUser?
    private var hasInitialized = false
    
    // Pagination threshold - load more when user scrolls to this many items from the end
    private let paginationThreshold = 6
    
    init() {
        // Initialize filteredUserQueue to match userQueue
        filteredUserQueue = userQueue
    }
    
    // MARK: - Search Methods
    
    /// Execute search - called when user taps Search button or presses Return
    func executeSearch() {
        activeSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        applySearchFilter()
    }
    
    /// Clear search and show all users
    func clearSearch() {
        searchText = ""
        activeSearchText = ""
        applySearchFilter()
    }
    
    /// Apply search filter to userQueue
    private func applySearchFilter() {
        if activeSearchText.isEmpty {
            // No search - show all users
            filteredUserQueue = userQueue
        } else {
            // Filter by name (case-insensitive)
            let lowercasedSearch = activeSearchText.lowercased()
            filteredUserQueue = userQueue.filter { user in
                guard let name = user.name else { return false }
                return name.lowercased().contains(lowercasedSearch)
            }
        }
        
        print("🔍 Search applied: '\(activeSearchText)' - \(filteredUserQueue.count) results")
    }
    
    // MARK: - User Loading
    
    func loadInitialUsers(for user: DBUser) {
        currentUser = user
        lastFilterHash = calculateFilterHash(for: user)
        userQueue = []
        filteredUserQueue = []
        activeSearchText = ""
        searchText = ""
        usersManager.resetPagination()
        hasInitialized = true
        fetchNextPage(for: user, isInitialLoad: true)
    }
    
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
                    print("Fetched \(users.count) users (initial: \(isInitialLoad))")
                    
                    if isInitialLoad {
                        self?.userQueue = users
                    } else {
                        // Filter out duplicates
                        let newUsers = users.filter { newUser in
                            !(self?.userQueue.contains { $0.uid == newUser.uid } ?? false)
                        }
                        self?.userQueue.append(contentsOf: newUsers)
                        print("Added \(newUsers.count) new users to queue")
                    }
                    

                    self?.applySearchFilter()
                    
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ Error fetching users: \(error)")
                }
            }
        }
    }
    

    
    func shouldLoadMore(currentUser: DBUser) -> Bool {

        guard let index = filteredUserQueue.firstIndex(where: { $0.uid == currentUser.uid }) else {
            return false
        }
        
        // Load more when we're within paginationThreshold items from the end
        let shouldLoad = index >= filteredUserQueue.count - paginationThreshold
        
        if shouldLoad && !isPaginating {
            print("📊 Should load more: index \(index) of \(filteredUserQueue.count)")
        }
        
        return shouldLoad && !isPaginating
    }
    
    // MARK: - Like/Dislike Actions
    
    func performLike(user: DBUser, currentUser: DBUser, isSubscriptionActive: Bool, completion: @escaping (Bool) -> Void) {
        // Check daily like limit
        if !isSubscriptionActive && (currentUser.dailyLikes ?? 0) <= 0 {
            showPayWall = true
            completion(false)
            return
        }
        
        // Remove from both queues immediately for better UX
        userQueue.removeAll { $0.uid == user.uid }
        filteredUserQueue.removeAll { $0.uid == user.uid }
        
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
            
            await MainActor.run {
                completion(true)
            }
        }
    }
    
    func performDislike(user: DBUser, currentUser: DBUser) {
        // Remove from both queues immediately
        userQueue.removeAll { $0.uid == user.uid }
        filteredUserQueue.removeAll { $0.uid == user.uid }
        
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
