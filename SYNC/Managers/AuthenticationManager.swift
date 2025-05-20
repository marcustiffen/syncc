import Combine
import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Foundation

class AuthenticationManager: ObservableObject {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    private let auth = Auth.auth()
    
    private var verificationId: String?
    
    
    
    @discardableResult
    func createUser(email: String, password: String, name: String, phoneNumber: String) async throws -> AuthDataResultModel {
        auth.currentUser?.email = email
        try await auth.currentUser?.updatePassword(to: password)
        auth.currentUser?.displayName = name
        auth.currentUser?.phoneNumber = phoneNumber
        let authDataResult = auth.currentUser
        
        return AuthDataResultModel(user: authDataResult!)
    }
    
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }

    
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    
    func sendPasswordResetEmail(to email: String) async throws {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Password reset error: \(error.localizedDescription)")
            } else {
                print("Password reset email sent successfully.")
            }
        }
    }
    
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

