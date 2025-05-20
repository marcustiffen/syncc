import Combine
import CoreLocation
import Foundation
import FirebaseFirestore


//MARK: Main Bits
class CompleteUsersModel: ProfileModel {
    @Published var lastDocumentSnapshot: DocumentSnapshot? = nil
    private let pageSize = 20
    @Published var hasMoreUsers = true
    
    
    @Published var allUsers: [DBUser] = []  {// All users in the whole users collection
        didSet {
            updateUserIds()
        }
    }
    
    var dismissedUserIds: [String] = []
    var matchUserIds: [String] = []
    var likesReceivedUserIds: [String] = []
    var likesSentUserIds: [String] = []
    var excludedUserIds: [String] = []
    
    // Update the user IDs whenever matches, likesReceived, or likesSent change
    private func updateUserIds() {
        dismissedUserIds = dismissedUsers.map { $0.userId }
        matchUserIds = matches.map { $0.userId }
        likesReceivedUserIds = likesReceived.map { $0.userId }
        likesSentUserIds = likesSent.map { $0.userId }
        excludedUserIds = Array(matchUserIds + likesSentUserIds + dismissedUserIds)
    }
    
    @Published var matches: [LikeReceived] = [] { // Users in the matches collection
        didSet {
            updateUserIds()
        }
    }
    @Published var likesReceived: [LikeReceived] = [] { // Users in likes_received collection
        didSet {
            updateUserIds()
            Task {
                try? await self.loadUsersForLikesReceived()
            }
        }
    }
    @Published var likesReceivedUsers: [DBUser] = [] {
        didSet {
            updateUserIds()
        }
    }
    @Published var likesSent: [LikeReceived] = [] { // Users in likes_sent collection
        didSet {
            updateUserIds()
        }
    }
    @Published var dismissedUsers: [LikeReceived] = [] { // Users in likes_sent collection
        didSet {
            updateUserIds()
        }
    }
    
    
    private let db = Firestore.firestore()
    
    
    //"users"
    private func usersCollection() -> CollectionReference {
        db.collection("users")
    }
    private var usersListener: ListenerRegistration? = nil
    private var usersCancellables = Set<AnyCancellable>()
    var usersListenerRegistered = false  // Track if the listener is already registered
    
    
    // "likes received"
    private func likesReceivedCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("likes_received")
    }
    private var likesReceivedCancellables = Set<AnyCancellable>()
    private var likesReceivedListener: ListenerRegistration? = nil
    var likesReceivedListenerRegistered = false  // Track if the listener is already registered

    
    // "likes sent"
    private func likesSentCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("likes_sent")
    }
    private var likesSentCancellables = Set<AnyCancellable>()
    private var likesSentListener: ListenerRegistration? = nil
    var likesSentListenerRegistered = false  // Track if the listener is already registered
    
    
    // "matches"
    private func matchesCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("matches")
    }
    private var matchesCancellables = Set<AnyCancellable>()
    private var matchesListener: ListenerRegistration? = nil
    var matchesListenerRegistered = false  // Track if the listener is already registered
    
    
    // "dismissed users"
    private func dismissedUsersCollection(userId: String) -> CollectionReference {
        db.collection("users").document(userId).collection("dismissed_users")
    }
    private var dismissedUsersCancellables = Set<AnyCancellable>()
    private var dismissedUsersListener: ListenerRegistration? = nil
    var dismissedUsersListenerRegistered = false  // Track if the listener is already registered

    
    func callAllListenersForUser(userId: String) {
        if !usersListenerRegistered {
            addListenerUsers(userId: userId)
        }
        if !likesReceivedListenerRegistered {
            addListenerForLikesReceived(userId: userId)
        }
        if !likesSentListenerRegistered {
            addListenerForLikesSent(userId: userId)
        }
        if !matchesListenerRegistered {
            addListenerForMatches(userId: userId)
        }
        if !dismissedUsersListenerRegistered {
            addListenerForDismissedUsers(userId: userId)
        }
    }
    
    
    func removeAllListeners() {
        removeUsersListener()
        removelikesReceivedListener()
        removelikesSentListener()
        removeMatchesListener()
        removedismissedUsersListener()
    }
    
    func removeUsersListener() {
        if !usersCancellables.isEmpty {
            usersListener?.remove()
            usersListenerRegistered = false
            usersCancellables.removeAll()
        }
    }
    
    func removelikesReceivedListener() {
        if !likesReceivedCancellables.isEmpty {
            likesReceivedListener?.remove()
            likesReceivedListenerRegistered = false
            likesReceivedCancellables.removeAll()
        }
    }
    
    func removelikesSentListener() {
        if !likesSentCancellables.isEmpty {
            likesSentListener?.remove()
            likesSentListenerRegistered = false
            likesSentCancellables.removeAll()
        }
    }
    
    func removeMatchesListener() {
        if !matchesCancellables.isEmpty {
            matchesListener?.remove()
            matchesListenerRegistered = false
            matchesCancellables.removeAll()
        }
    }
    
    func removedismissedUsersListener() {
        if !dismissedUsersCancellables.isEmpty {
            dismissedUsersListener?.remove()
            dismissedUsersListenerRegistered = false
            dismissedUsersCancellables.removeAll()
        }
    }
}


//MARK: users
extension CompleteUsersModel {
    
    func addListenerUsers(userId: String) {
        guard !usersListenerRegistered else { return }  // Ensure listener is added only once
        usersListenerRegistered = true  // Mark listener as registered
        
        getUsers(uid: userId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error in chatrooms listener: \(error)")
                }
            } receiveValue: { [weak self] users in
                self?.allUsers = users
            }
            .store(in: &likesReceivedCancellables)
    }
    
    func getUsers(uid: String) -> AnyPublisher<[DBUser], any Error> {
        let usersCollection = usersCollection().whereField("uid", isNotEqualTo: uid)
        let (publisher, listener) = usersCollection.addSnapShotListener(as: DBUser.self)
        self.usersListener = listener
        return publisher
    }
}


//MARK: likes received
extension CompleteUsersModel {
    func addListenerForLikesReceived(userId: String) {
        guard !likesReceivedListenerRegistered else { return }  // Ensure listener is added only once
        likesReceivedListenerRegistered = true  // Mark listener as registered
        
        getLikesReceived(uid: userId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error in chatrooms listener: \(error)")
                }
            } receiveValue: { [weak self] likesReceived in
                self?.likesReceived = likesReceived
            }
            .store(in: &likesReceivedCancellables)
    }
    
    func getLikesReceived(uid: String) -> AnyPublisher<[LikeReceived], any Error> {
        let likesReceivedCollection = likesReceivedCollection(userId: uid)
        let (publisher, listener) = likesReceivedCollection.addSnapShotListener(as: LikeReceived.self)
        self.likesReceivedListener = listener
        return publisher
    }
}


//MARK: likes sent
extension CompleteUsersModel {
    func addListenerForLikesSent(userId: String) {
        guard !likesSentListenerRegistered else { return }  // Ensure listener is added only once
        likesSentListenerRegistered = true  // Mark listener as registered
        
        getLikesSent(uid: userId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error in chatrooms listener: \(error)")
                }
            } receiveValue: { [weak self] likesSent in
                self?.likesSent = likesSent
            }
            .store(in: &likesSentCancellables)
    }
    
    func getLikesSent(uid: String) -> AnyPublisher<[LikeReceived], any Error> {
        let likesSentCollection = likesSentCollection(userId: uid)
        let (publisher, listener) = likesSentCollection.addSnapShotListener(as: LikeReceived.self)
        self.likesSentListener = listener
        return publisher
    }
}


//MARK: matches
extension CompleteUsersModel {
    func addListenerForMatches(userId: String) {
        guard !matchesListenerRegistered else { return }  // Ensure listener is added only once
        matchesListenerRegistered = true  // Mark listener as registered
        
        getMatches(uid: userId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error in chatrooms listener: \(error)")
                }
            } receiveValue: { [weak self] matches in
                self?.matches = matches
            }
            .store(in: &matchesCancellables)
    }
    
    func getMatches(uid: String) -> AnyPublisher<[LikeReceived], any Error> {
        let matchesCollection = matchesCollection(userId: uid)
        let (publisher, listener) = matchesCollection.addSnapShotListener(as: LikeReceived.self)
        self.matchesListener = listener
        return publisher
    }
}


//MARK: dismissed users
extension CompleteUsersModel {
    func addListenerForDismissedUsers(userId: String) {
        guard !dismissedUsersListenerRegistered else { return }  // Ensure listener is added only once
        dismissedUsersListenerRegistered = true  // Mark listener as registered
        
        getDismissedUsers(uid: userId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error in chatrooms listener: \(error)")
                }
            } receiveValue: { [weak self] dismissedUsers in
                self?.dismissedUsers = dismissedUsers
            }
            .store(in: &dismissedUsersCancellables)
    }
    
    func getDismissedUsers(uid: String) -> AnyPublisher<[LikeReceived], any Error> {
        let dismissedUsersCollection = dismissedUsersCollection(userId: uid)
        let (publisher, listener) = dismissedUsersCollection.addSnapShotListener(as: LikeReceived.self)
        self.dismissedUsersListener = listener
        return publisher
    }
}


//MARK: Misc
extension CompleteUsersModel {
    func loadUsersForLikesReceived() async throws {
        let users: [DBUser] = try await withThrowingTaskGroup(of: DBUser.self) { group in
            for like in likesReceived {
                group.addTask {
                    try await DBUserManager.shared.getUser(uid: like.userId)
                }
            }

            var results: [DBUser] = []
            for try await user in group {
                results.append(user)
            }
            return results
        }

        // Ensure state updates happen on the main thread
        await MainActor.run {
            self.likesReceivedUsers = users
        }
    }
//    func loadUsersForLikesReceived() async throws {
//        var users = [DBUser]()
//        
//        for like in likesReceived {
//            // Fetch the user document for each userId in likesReceived
//            let userDoc = try? await usersCollection().document(like.userId).getDocument()
//            if let userDoc = userDoc, userDoc.exists,
//               let user = try? userDoc.data(as: DBUser.self) {
//                users.append(user)
//            }
//        }
//        
//        // Update on the main thread
//        await MainActor.run {
//            self.likesReceivedUsers = users
//        }
//    }
}
