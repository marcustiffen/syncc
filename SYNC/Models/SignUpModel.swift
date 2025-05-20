import FirebaseAuth
import Foundation
import PhotosUI


@MainActor
final class SignUpModel: ObservableObject {
    @Published var phoneNumber: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var dateOfBirth: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @Published var sex: String = "Male"
    @Published var location: DBLocation = .init()
    @Published var bio: String = ""
    @Published var fitnessTypes: [FitnessType] = []
    @Published var fitnessGoals: [FitnessGoal] = []
    @Published var fitnessLevel: String = "Beginner"
    @Published var height: Int = 0
    @Published var weight: Double = 0.0
    
    @Published var selectedImages: [UIImage] = [] // Temporary selected images
//    @Published var imageUrls: [String] = [] // Final URLs for Firestore
    @Published var images: [DBImage] = []
    
    @Published var filteredAgeRange: CustomRange = CustomRange(min: 18, max: 100)
    @Published var filteredSex: String = "Male"
    @Published var filteredMatchRadius: Double = 50.0
    @Published var filteredFitnessTypes: [FitnessType] = []
    @Published var filteredFitnessGoals: [FitnessGoal] = []
    @Published var filteredFitnessLevel: String = "Beginner"
    
    
    @Published var loadingMessage = ""
    

//    func createAccount() async throws -> DBUser {
//        let userId = Auth.auth().currentUser?.uid ?? ""
//
//        // Convert DBImage objects to UIImages for upload
//        let uiSelectedImages = images.map { $0.uiImage }
//
//        loadingMessage = "Uploading images..."
//        // Upload images and get their URLs
//        let urls = await DBUserManager.shared.uploadPhoto(selectedImages: uiSelectedImages, uid: userId)
//
//        // Ensure the URLs are correctly assigned to the corresponding DBImage objects
//        var updatedImages = images
//        for (index, url) in urls.enumerated() {
//            if index < updatedImages.count {
//                updatedImages[index].url = url
//            }
//        }
//        
//        loadingMessage = "Creating account..."
//        
//        // Create user object with updated image URLs
//        let createdUser = DBUser(
//            uid: userId,
//            phoneNumber: phoneNumber,
//            email: email,
//            name: "\(firstName) \(lastName)",
//            dateOfBirth: dateOfBirth,
//            sex: sex,
//            location: location,
//            bio: bio,
//            fitnessTypes: fitnessTypes,
//            fitnessGoals: fitnessGoals,
//            fitnessLevel: fitnessLevel,
//            height: height,
//            weight: weight,
//            images: updatedImages,  // Now has the correct URLs
//            filteredAgeRange: filteredAgeRange,
//            filteredSex: filteredSex,
//            filteredMatchRadius: filteredMatchRadius,
//            filteredFitnessTypes: filteredFitnessTypes,
//            filteredFitnessGoals: filteredFitnessGoals,
//            filteredFitnessLevel: filteredFitnessLevel,
//            isBanned: false
//        )
//        
//        loadingMessage = "Nearly there..."
//
//        // Save user in Firestore
//        try await DBUserManager.shared.createNewUser(user: createdUser)
//
//        return createdUser
//    }
    func createAccount() async throws -> DBUser {
        let userId = Auth.auth().currentUser?.uid ?? ""

        // Convert DBImage objects to UIImages for upload
        let uiSelectedImages = images.map { $0.uiImage }

        loadingMessage = "Preparing images for upload..."
        
        // Start uploading images and continue with account creation
        loadingMessage = "Uploading images..."
        let urls = await DBUserManager.shared.uploadPhoto(selectedImages: uiSelectedImages, uid: userId)

        // Ensure the URLs are correctly assigned to the corresponding DBImage objects
        var updatedImages = images
        for (index, url) in urls.enumerated() {
            if index < updatedImages.count {
                updatedImages[index].url = url
            }
        }
        
        loadingMessage = "Creating account..."
        
        // Create user object with updated image URLs
        let createdUser = DBUser(
            uid: userId,
            phoneNumber: phoneNumber,
            email: email,
            name: "\(firstName) \(lastName)",
            dateOfBirth: dateOfBirth,
            sex: sex,
            location: location,
            bio: bio,
            fitnessTypes: fitnessTypes,
            fitnessGoals: fitnessGoals,
            fitnessLevel: fitnessLevel,
            height: height,
            weight: weight,
            images: updatedImages,  // Now has the correct URLs
            filteredAgeRange: filteredAgeRange,
            filteredSex: filteredSex,
            filteredMatchRadius: filteredMatchRadius,
            filteredFitnessTypes: filteredFitnessTypes,
            filteredFitnessGoals: filteredFitnessGoals,
            filteredFitnessLevel: filteredFitnessLevel,
            isBanned: false,
            dailyLikes: 3
        )
        
        loadingMessage = "Almost there..."

        // Save user in Firestore
        try await DBUserManager.shared.createNewUser(user: createdUser)

        return createdUser
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
