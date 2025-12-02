import FirebaseAuth
import SwiftUI
import Foundation
import PhotosUI


@MainActor
final class SignUpModel: ObservableObject {
    
    init() {
        Task {
//            await fetchUserData()
            await fetchUserOnBoardingStatus()
        }
    }
    
    @Published var onboardingStep: OnboardingStep = .phone
    
    @Published var uid: String? = ""
    
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @Published var sex: String = "Male"
    @Published var location: DBLocation = .init()
    @Published var bio: String = ""
    @Published var fitnessTypes: [String] = []
    @Published var fitnessGoals: [String] = []
    @Published var fitnessLevel: String = "Beginner"
    @Published var height: Int = 100
    @Published var weight: Double = 0.0
    
    @Published var selectedImages: [UIImage] = [] // Temporary selected images
    @Published var images: [DBImage] = []
    
    @Published var filteredAgeRange: CustomRange = CustomRange(min: 18, max: 99)
    @Published var filteredSex: String = "Both"
    @Published var filteredMatchRadius: Double = 50.0
    @Published var filteredFitnessTypes: [String] = []
    @Published var filteredFitnessGoals: [String] = []
    @Published var filteredFitnessLevel: String = "Beginner"
    @Published var blockedSex: String = "None"
    
    @Published var loadingMessage = ""
            

    func createAccount() async throws -> DBUser {
        let createdUser = try await DBUserManager.shared.getUser(uid: uid!)
        return createdUser
    }
    
    
    func setUser() async throws -> DBUser {
        let firestoreUser = try await DBUserManager.shared.getUser(uid: uid!)
        return firestoreUser
    }
    
    
    func fetchUserOnBoardingStatus() async {
        do {
            guard let currentUser = Auth.auth().currentUser else { return }
            
            let result = try await OnboardingStateManager.shared.fetchOnboardingStatus(uid: currentUser.uid)
            print("\(String(describing: result?.rawValue))")
            self.uid = currentUser.uid
            print("UID: \(String(describing: self.uid))")
            self.onboardingStep = result ?? .phone // ← SET IT HERE
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    func saveOnboardingStep(uid: String, onboardingStep: OnboardingStep) async {
        await OnboardingStateManager.shared.saveOnboardingProgress(uid: uid, step: onboardingStep)
    }
    
    
    func saveProgress(uid: String, key: String?, value: Any?, onboardingStep: OnboardingStep?) async {
        if let onboardingStep = onboardingStep {
            await saveOnboardingStep(uid: uid, onboardingStep: onboardingStep)
            self.onboardingStep = onboardingStep
        }
        if let key = key, let value = value {
            await OnboardingStateManager.shared.updateUserValue(uid: uid, key: key, value: value)
        }
    }
    
    
    func linkEmailToPhoneCredential(completion: @escaping (Bool, String?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(false, "No authenticated user found.")
            return
        }
        let emailCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        currentUser.link(with: emailCredential) { authResult, error in
            if let error = error {
                print("Error linking email to phone credential: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
            } else {
                print("Email successfully linked to phone credential.")
                completion(true, nil)
            }
        }
    }
    
    
    func signIn(email: String, password: String) async throws {
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
        print("User signed in")
    }
}
