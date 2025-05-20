import Combine
import FirebaseAuth
import FirebaseFirestore
import Foundation
import RevenueCat

@MainActor
class ProfileModel: ObservableObject {
    
    @Published var user: DBUser? = nil
    
//    @Published var isSubscriptionActive = false
//    init() {
//        Purchases.shared.getCustomerInfo { (customerInfo, error) in
//            self.isSubscriptionActive = customerInfo?.entitlements.all["Premium"]?.isActive == true
//        }
//    }
    
    

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
            
            self.user = data // Update the user property in real-time
        }
    }
    

    func removeListener() {
        userListener?.remove()
        userListenerRegistered = false
    }
    
        
//    func deleteUser() async throws {
//        guard let uid = user?.uid else { return }
//        Auth.auth().currentUser?.delete { error in
//            switch error {
//            case .none:
//                print("No error")
//            default :
//                print("user deletion success")
//            }
//        }
//        DBUserManager.shared.deleteUser(uid: uid) { error in
//            switch error {
//            case .success(let success):
//                Task {
//                    if !self.userCancellables.isEmpty {
//                        self.userCancellables.removeAll()
//                    }
//                    self.removeListener()
//                    CompleteUsersModel().removeAllListeners()
//                    MessagesManager.shared.removeListener()
//                    ChatRoomsManager().removeListener()
//                    self.user = nil
//                    print("Successfully deleted user: \(success)")
//                }
//            case .failure(let failure):
//                print("Failed to delete user: \(failure)")
//            }
//        }
//    }
    
    func deleteUser(uid: String, email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else { return }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        user.reauthenticate(with: credential) { authResult, error in
            if let error = error {
                print("Reauthentication failed: \(error.localizedDescription)")
                return
            }

            user.delete { error in
                if let error = error {
                    print("Failed to delete user from Auth: \(error.localizedDescription)")
                    return
                }

                print("Firebase Auth user deleted successfully")

                // Proceed to delete user data from your database
                DBUserManager.shared.deleteUser(uid: uid) { error in
                    switch error {
                    case .success(let success):
                        Task {
                            if !self.userCancellables.isEmpty {
                                self.userCancellables.removeAll()
                            }
                            self.removeListener()
                            CompleteUsersModel().removeAllListeners()
                            MessagesManager.shared.removeListener()
                            ChatRoomsManager().removeListener()
                            self.user = nil
                            print("Successfully deleted user: \(success)")
                        }
                    case .failure(let failure):
                        print("Failed to delete user: \(failure)")
                    }
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
    
    func setUserDeviceToken(uid: String) async {
        if let token = UserDefaults.standard.string(forKey: "FCMToken") {
            await DBUserManager.shared.updateFCMTokenForUser(uid: uid, token: token)
        }
    }
    
    
    func signOut() throws {
        removeListener()
        CompleteUsersModel().removeAllListeners()
        MessagesManager.shared.removeListener()
        ChatRoomsManager().removeListener()
        try Auth.auth().signOut()
        self.user = nil
        print("User on device: \(String(describing: user))")
    }
}




