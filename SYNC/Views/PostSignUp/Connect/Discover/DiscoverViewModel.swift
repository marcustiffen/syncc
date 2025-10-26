import Combine
import CoreLocation
import Foundation
import FirebaseFirestore



class DiscoverViewModel: ObservableObject {
    @Published var cardQueue: [DBUser] = []
    @Published var isLoading = false
    @Published var isAnimating = false
    @Published var showLikeIndicator = false
    @Published var showPayWall = false
    @Published var errorMessage: String?
    
    // Track if this is the first load vs background fetching
    @Published var isFirstLoad = true
    @Published var isBackgroundFetching = false
    @Published var animatedCardIds: Set<String> = []
    
    // Add flag to prevent redundant filter checks
    private var hasInitialized = false

    private let usersManager = UsersManager()
    private let matchMakingManager = MatchMakingManager()
    private var lastActionTime: Date = .distantPast
    private let debounceInterval: TimeInterval = 0.25
    private var lastFilterHash: Int = 0
    private var currentUser: DBUser?
    private var isPaginating = false

    func loadInitialUsers(for user: DBUser) {
        currentUser = user
        lastFilterHash = calculateFilterHash(for: user)
        cardQueue = []
        isFirstLoad = true
        isBackgroundFetching = false
        animatedCardIds.removeAll()
        usersManager.resetPagination()
        hasInitialized = true // Mark as initialized
        fetchNextPage(reset: true, isInitialLoad: true)
    }

    func fetchNextPage(reset: Bool = false, isInitialLoad: Bool = false) {
        guard let user = currentUser, !isPaginating else { return }
        isPaginating = true
        isLoading = true
        
        // Set background fetching flag for animation control
        if !isInitialLoad {
            isBackgroundFetching = true
        }
        
        // Determine fetch size based on context
        let fetchSize: Int
        if isInitialLoad {
            fetchSize = 10 // Initial load: fetch up to 10 users
        } else {
            fetchSize = 7 // Background refetch: fetch exactly 7 users
        }
        
        usersManager.fetchUsers(for: user, pageSize: fetchSize, reset: reset) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isPaginating = false
                switch result {
                case .success(let users):
                    let newUsers = users.filter { newUser in
                        !(self?.cardQueue.contains { $0.uid == newUser.uid } ?? false)
                    }
                    if reset {
                        self?.cardQueue = newUsers
                    } else {
                        self?.cardQueue.append(contentsOf: newUsers)
                    }
                    
                    // Mark first load as complete after first successful fetch
                    if self?.isFirstLoad == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self?.isFirstLoad = false
                        }
                    }
                    
                    // Reset background fetching flag after a short delay
                    if self?.isBackgroundFetching == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self?.isBackgroundFetching = false
                        }
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isBackgroundFetching = false
                }
            }
        }
    }

    func performCardAction(isLike: Bool, user: DBUser, currentUser: DBUser, isSubscriptionActive: Bool) {
        guard !isAnimating else { return }
        let now = Date()
        guard now.timeIntervalSince(lastActionTime) > debounceInterval else { return }
        lastActionTime = now
        
        if isLike && !isSubscriptionActive && currentUser.dailyLikes! < 0  {
            showPayWall = true
            return
        }
        
        isAnimating = true
        if isLike {
            sendLike(currentUser: currentUser, user: user, isSubscriptionActive: isSubscriptionActive)
        } else {
            sendDislike(currentUser: currentUser, user: user)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.advanceQueue()
            self.isAnimating = false
        }
    }

    private func advanceQueue() {
        if !cardQueue.isEmpty {
            let removedUser = cardQueue.removeFirst()
            cardQueue.removeAll { $0.uid == removedUser.uid }
            
            // Remove from animated cards set
            animatedCardIds.remove(removedUser.uid)
            
            // Fetch more users when count drops to 3
            if cardQueue.count <= 3 {
                fetchNextPage(isInitialLoad: false)
            }
        }
    }

    private func sendLike(currentUser: DBUser, user: DBUser, isSubscriptionActive: Bool) {
        Task.detached { [weak self] in
            await withCheckedContinuation { continuation in
                self?.matchMakingManager.sendLike(
                    currentUserId: currentUser.uid,
                    likedUserId: user.uid,
                    isSubscriptionActive: isSubscriptionActive
                ) { _ in continuation.resume() }
            }
        }
    }

    private func sendDislike(currentUser: DBUser, user: DBUser) {
        Task { [weak self] in
            await self?.matchMakingManager.dismissUser(
                currentUserId: currentUser.uid,
                dismissedUserId: user.uid
            )
        }
    }

    // MODIFIED: Add guard to prevent redundant calls
    func checkFiltersAndReloadIfNeeded(for user: DBUser) {
        guard hasInitialized else {
            print("Not initialized yet, skipping filter check")
            return
        }
        
        let newFilterHash = calculateFilterHash(for: user)
        if newFilterHash != lastFilterHash {
            print("Filters changed, reloading users")
            loadInitialUsers(for: user)
        } else {
            print("Filters unchanged, maintaining queue")
            checkAndMaintainCardCount()
        }
    }

    func filtersDidChange(for user: DBUser) {
        let newFilterHash = calculateFilterHash(for: user)
        if newFilterHash != lastFilterHash {
            loadInitialUsers(for: user)
        }
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
        hasher.combine(user.blockedSex) // Add this if it affects filtering
        return hasher.finalize()
    }
    
    // Check if we need to fetch more cards to maintain the desired count
    func checkAndMaintainCardCount() {
        if cardQueue.count <= 3 {
            fetchNextPage(isInitialLoad: false)
        }
    }
    
    // Reset animation state for new filter results
    func resetAnimationState() {
        isFirstLoad = true
        isBackgroundFetching = false
        animatedCardIds.removeAll()
    }
}
