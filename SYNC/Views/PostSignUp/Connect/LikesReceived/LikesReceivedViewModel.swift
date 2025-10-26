import Combine
import Firebase
import SwiftUI
import CoreLocation


@MainActor
class LikesReceivedViewModel: ObservableObject {
    @Published var likesReceived: [LikeReceived] = []
    @Published var usersWhoLiked: [DBUser] = []
    @Published var isLoading = false
    @Published var animatedUsers: [DBUser] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let usersManager = UsersManager()
    private let matchMakingManager = MatchMakingManager()
    private let notificationManager = NotificationManager()
    
    func addListenerForLikesReceived(for currentUserId: String) {
        usersManager.addListenerForLikesReceived(userId: currentUserId)
            .sink { completion in
                // Handle error if needed
            } receiveValue: { [weak self] likesReceived in
                self?.likesReceived = likesReceived
                Task {
                    await self?.fetchUsersForLikes()
                }
            }
            .store(in: &cancellables)
    }
    

    func fetchUsersForLikes() async {
        isLoading = true
        animatedUsers = [] // Clear animated users when starting fresh
        var fetchedUsers: [DBUser] = []

        // Deduplicate user IDs
        let uniqueUserIds = Array(Set(likesReceived.map { $0.userId }))

        await withTaskGroup(of: DBUser?.self) { group in
            for userId in uniqueUserIds {
                group.addTask {
                    await self.fetchUser(userId: userId)
                }
            }
            for await user in group {
                if let user = user {
                    fetchedUsers.append(user)
                }
            }
        }

        usersWhoLiked = fetchedUsers
        isLoading = false

        // Animate users in with staggered delays
        await animateUsersIn()
    }
    
    private func animateUsersIn() async {
        for (index, user) in usersWhoLiked.enumerated() {
            // Stagger the animations with increasing delays
            let delay = Double(index) * 0.1 // 100ms delay between each user
            
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)) {
                animatedUsers.append(user)
            }
        }
    }
    
    private func fetchUser(userId: String) async -> DBUser? {
        do {
            return try await DBUserManager.shared.getUser(uid: userId)
        } catch {
            print("Error fetching user \(userId): \(error)")
            return nil
        }
    }
    
    func sendLike(currentUser: DBUser, user: DBUser, isSubscriptionActive: Bool) {
        sendMatchNotification(to: user, from: currentUser)
        Task.detached { [weak self] in
            await withCheckedContinuation { continuation in
                self?.matchMakingManager.sendLike(
                    currentUserId: currentUser.uid,
                    likedUserId: user.uid,
                    isSubscriptionActive: isSubscriptionActive
                ) { result in
                    continuation.resume()
                }
            }
        }
    }
    
    
    func sendDislike(currentUser: DBUser, user: DBUser) {
        Task { [weak self] in
            await self?.matchMakingManager.dismissUser(
                currentUserId: currentUser.uid,
                dismissedUserId: user.uid
            )
        }
    }
    
    
    private func sendMatchNotification(to user: DBUser, from currentUser: DBUser) {
        guard let recipientToken = user.fcmToken else {
            print("No FCM token found for user: \(user.uid)")
            return
        }
        
        let sendingFullName = currentUser.name ?? "Someone"
        let sendingNameComponents = sendingFullName.split(separator: " ")
        let sendingFirstName = String(sendingNameComponents.first ?? "")
        
        
        let senderName = sendingFirstName
        let title = "Syncc"
        let message = "It's a match! \(senderName) wants to Syncc up!"
        
        notificationManager.sendSingularPushNotification(
            token: recipientToken,
            message: message,
            title: title
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Match notification sent successfully to \(user.name ?? "user")")
                case .failure(let error):
                    print("Failed to send match notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    private func dismissUser(currentUserId: String, dismissedUserId: String) {
        Task {
            await MatchMakingManager.shared.dismissUser(currentUserId: currentUserId, dismissedUserId: dismissedUserId)
        }
    }
}
