import Foundation
import FirebaseFirestore

@MainActor
class OnboardingStateManager: ObservableObject {
    
    static let shared = OnboardingStateManager()
        
    private let db = Firestore.firestore()
    
    
    private func usersCollection() -> CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    
    private func userDocument(uid: String) -> DocumentReference {
        usersCollection().document(uid)
    }
    
    
    func saveOnboardingProgress(uid: String, step: OnboardingStep) async {
        do {
            let data: [String: Any] = [
                "onboardingStep": step.rawValue
            ]
            try await db.collection("users").document(uid).setData(data, merge: true)
            print("Onboarding progress saved: \(step.rawValue)")
        } catch {
            print("Error saving onboarding progress: \(error)")
        }
    }
    
    
    func updateUserValue(uid: String, key: String, value: Any) async {
        do {
            let data: [String: Any] = [
                key: value
            ]
            try await db.collection("users").document(uid).setData(data, merge: true)
        } catch {
            print("Error saving onboarding progress: \(error)")
        }
    }
    
    
    func fetchOnboardingStatus(uid: String) async throws -> OnboardingStep? {
        let snapshot = try await userDocument(uid: uid).getDocument()
        
        guard let data = snapshot.data(),
              let rawStep = data["onboardingStep"] as? String,
              let step = OnboardingStep(rawValue: rawStep) else {
            return nil // or throw an error if you want
        }

        return step
    }
}
