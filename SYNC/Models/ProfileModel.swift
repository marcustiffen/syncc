import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import RevenueCat

@MainActor
class ProfileModel: ObservableObject {
    
    @Published var user: DBUser? = nil

    private let db = Firestore.firestore()
    private var userListener: ListenerRegistration? = nil
    private var userCancellables = Set<AnyCancellable>()
    var userListenerRegistered = false  // Track if the listener is already registered
    
    
    func addListenerForCurrentUser(userId: String) {
        guard userListener == nil else { return } // Ensure listener is added only once
        
        let documentRef = db.collection("users").document(userId)
        
        // Add snapshot listener for the user document
        userListener = documentRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening to user document: \(error)")
                return
            }
            
            guard let document = snapshot, document.exists,
                  let data = try? document.data(as: DBUser.self) else {
                print("User document does not exist or cannot be decoded.")
                return
            }
            
            self.user = data
        }
    }
    

    func deleteUser(uid: String, email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw ProfileModelError.userNotFound
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        // Convert callback-based reauthenticate to async/await
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.reauthenticate(with: credential) { authResult, error in
                if let error = error {
                    print("Reauthentication failed: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
        
        // Convert callback-based delete to async/await
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            user.delete { error in
                if let error = error {
                    print("Failed to delete user from Auth: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                print("Firebase Auth user deleted successfully")
                continuation.resume(returning: ())
            }
        }
        
        // Convert DBUserManager delete to async/await
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DBUserManager.shared.deleteUser(uid: uid) { error in
                switch error {
                case .success(let success):
                    Task { @MainActor in
                        if !self.userCancellables.isEmpty {
                            self.userCancellables.removeAll()
                        }
                        self.removeListener()
//                        CompleteUsersModel().removeAllListeners()
                        self.user = nil
                        print("Successfully deleted user: \(success)")
                    }
                    continuation.resume(returning: ())
                case .failure(let failure):
                    print("Failed to delete user: \(failure)")
                    continuation.resume(throwing: failure)
                }
            }
        }
    }

    
    func loadCurrentUser() async -> DBUser? {
        do {
            let authedUser = try AuthenticationManager.shared.getAuthenticatedUser()
            let currentUser = try await DBUserManager.shared.getUser(uid: authedUser.uid)
            
            self.user = currentUser  // Set initial user data
            addListenerForCurrentUser(userId: authedUser.uid)  // Start real-time updates
            
            if user?.fcmToken != UserDefaults.standard.string(forKey: "FCMToken") {
                await setUserDeviceToken(uid: authedUser.uid)
            }
            
            return currentUser
        } catch {
            print("Error loading user: \(error)")
            return nil
        }
    }
    
    
    func removeListener() {
        userListener?.remove()
        userListenerRegistered = false
    }
    
    
    func resetNonAdmin(uid: String) async {
        await DBUserManager.shared.updateNonPremiumUserInfo(uid: uid)
    }
    
    
    func setUserDeviceToken(uid: String) async {
        if let token = UserDefaults.standard.string(forKey: "FCMToken") {
            await DBUserManager.shared.updateFCMTokenForUser(uid: uid, token: token)
        }
    }
    
    
    func shouldResetLikes(lastResetDate: Date?) -> Bool {
        guard let lastReset = lastResetDate else {
            // If no reset date exists, we should reset
            return true
        }
        
        let twelveHoursInSeconds: TimeInterval = 12 * 60 * 60
        let timeSinceLastReset = Date().timeIntervalSince(lastReset)
        
        return timeSinceLastReset >= twelveHoursInSeconds
    }
    
    func resetDailyLikes(uid: String) async {
        await DBUserManager.shared.resetDailyLikesForUser(uid: uid)
    }
    
    
    func signOut() throws {
        removeListener()
//        CompleteUsersModel().removeAllListeners()
//        MessagesManager.shared.removeListener()
//        ChatRoomsManager().removeListener()
//        ChatRoomsManager().startListening(for: userId)
        try Auth.auth().signOut()
        self.user = nil
        print("User on device: \(String(describing: user))")
    }
}




