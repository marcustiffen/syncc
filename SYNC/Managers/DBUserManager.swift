import Combine
import FirebaseFunctions
import CoreLocation
import FirebaseFirestore
import FirebaseStorage
import Foundation


class DBUserManager: ObservableObject {
    
    private let functions = Functions.functions()
    
    static let shared = DBUserManager()
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        return decoder
    }()
    
    private func usersCollection() -> CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    private func userDocument(uid: String) -> DocumentReference {
        usersCollection().document(uid)
    }
    
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(uid: user.uid).setData(from: user, merge: false)
    }
    
    
    func deleteUser(uid: String, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/deleteUser") else {
                completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let parameters = ["uid": uid]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                completion(.failure(error))
                return
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(NSError(domain: "No HTTP Response", code: -2, userInfo: nil)))
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    if let resultString = String(data: data!, encoding: .utf8) {
                        completion(.success(resultString))
                    } else {
                        completion(.failure(NSError(domain: "Response parsing failed", code: -3, userInfo: nil)))
                    }
                default:
                    let errorData = data.flatMap { String(data: $0, encoding: .utf8) }
                    completion(.failure(NSError(domain: "Server Error: \(errorData ?? "Unknown")", code: httpResponse.statusCode, userInfo: nil)))
                }
            }.resume()
        }
    }
    
    
    func getUser(uid: String) async throws -> DBUser {
        try await userDocument(uid: uid).getDocument(as: DBUser.self)
    }
    
    
    func updateUser(_ user: DBUser) async throws {
        do {
            // Update the user document in Firestore with the encoded data from the user object
            try userDocument(uid: user.uid).setData(from: user, merge: true)
            print("User successfully updated in Firestore.")
        } catch {
            print("Failed to update user in Firestore: \(error)")
            throw error
        }
    }
    
    func updateImageData(userId: String, updatedImage: DBImage) async throws {
        let userDoc = userDocument(uid: userId)

        // Fetch the current user data
        let snapshot = try await userDoc.getDocument()
        guard let data = snapshot.data(),
              var imageDicts = data["images"] as? [[String: Any]] else {
            throw NSError(domain: "No image data", code: 404)
        }

        // Find and update the matching image by URL
        if let index = imageDicts.firstIndex(where: { $0["url"] as? String == updatedImage.url }) {
            // Store as arrays instead of dictionaries with named keys
            imageDicts[index]["offsetX"] = [updatedImage.offsetX.width, updatedImage.offsetX.height]
            imageDicts[index]["offsetY"] = [updatedImage.offsetY.width, updatedImage.offsetY.height]
            imageDicts[index]["scale"] = updatedImage.scale

            // Save the updated array back
            try await userDoc.updateData(["images": imageDicts])
        } else {
            throw NSError(domain: "Image not found", code: 404)
        }
    }

    
    
//    func updateUserFields(userId: String, field: String ,value: Any) async throws {
//        do {
//            let data: [String: Any] = [
//                field: value
//            ]
//            try await userDocument(uid: userId).setData(data, merge: true)
//        } catch {
//            print("Error updating user fields: \(error)")
//        }
//    }
    
    
    func updateFCMTokenForUser(uid: String, token: String) async {
        do {
            try await userDocument(uid: uid).setData(["fcmToken": token], merge: true)
        } catch {
            print("Error fetching or updating FCM token: \(error)")
        }
    }
}


//MARK: Images
extension DBUserManager {
    //v1
//    func uploadPhoto(selectedImages: [UIImage], uid: String) async -> [String] {
//        var downloadURLs: [String] = []
//        let storageRef = Storage.storage(url: "gs://sync-69d00.firebasestorage.app").reference()
//        
//        for selectedImage in selectedImages {
//            if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
//                let path = "images/\(uid)/\(UUID().uuidString).jpg"
//                let fileRef = storageRef.child(path)
//                
//                do {
//                    // Upload the image
//                    _ = try await fileRef.putDataAsync(imageData)
//                    
//                    // Fetch the download URL
//                    let downloadURL = try await fileRef.downloadURL()
//                    downloadURLs.append(downloadURL.absoluteString)
//                    
//                    print("Successfully uploaded image and retrieved URL: \(downloadURL.absoluteString)")
//                } catch {
//                    print("Error uploading image or retrieving URL: \(error.localizedDescription)")
//                }
//            } else {
//                print("Failed to convert image to JPEG format.")
//            }
//        }
//        
//        return downloadURLs
//    }
    
    //v2
    func uploadPhoto(selectedImages: [UIImage], uid: String) async -> [String] {
        let storageRef = Storage.storage(url: "gs://sync-69d00.firebasestorage.app").reference()
        
        // Use a task group to upload images concurrently
        return await withTaskGroup(of: (Int, String?).self) { group in
            var downloadURLs = Array(repeating: "", count: selectedImages.count)
            
            // Add each image upload as a separate task
            for (index, image) in selectedImages.enumerated() {
                group.addTask {
                    // Process image on background thread
                    let processedImage = await self.processImageForUpload(image)
                    
                    guard let imageData = processedImage.jpegData(compressionQuality: 0.7) else {
                        print("Failed to convert image \(index) to JPEG format.")
                        return (index, nil)
                    }
                    
                    let path = "images/\(uid)/\(UUID().uuidString).jpg"
                    let fileRef = storageRef.child(path)
                    
                    do {
                        // Configure metadata for better caching
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        metadata.cacheControl = "public, max-age=31536000"
                        
                        // Upload the image with metadata
                        _ = try await fileRef.putDataAsync(imageData, metadata: metadata)
                        
                        // Fetch the download URL
                        let downloadURL = try await fileRef.downloadURL()
                        print("Successfully uploaded image \(index) and retrieved URL")
                        return (index, downloadURL.absoluteString)
                    } catch {
                        print("Error uploading image \(index): \(error.localizedDescription)")
                        return (index, nil)
                    }
                }
            }
            
            // Process results as they complete
            for await (index, url) in group {
                if let url = url {
                    downloadURLs[index] = url
                }
            }
            
            // Filter out any empty URLs that might have failed
            return downloadURLs.filter { !$0.isEmpty }
        }
    }
    
    // Pre-process images to reduce size before uploading
    private func processImageForUpload(_ image: UIImage) async -> UIImage {
        return await Task.detached(priority: .background) {
            let targetSize = CGSize(width: 1200, height: 1200)
            let aspectRatio = image.size.width / image.size.height
            
            var newSize: CGSize
            if aspectRatio > 1 {
                // Landscape
                newSize = CGSize(width: targetSize.width, height: targetSize.width / aspectRatio)
            } else {
                // Portrait
                newSize = CGSize(width: targetSize.height * aspectRatio, height: targetSize.height)
            }
            
            // Don't resize if the image is already smaller than target
            if image.size.width <= targetSize.width && image.size.height <= targetSize.height {
                return image
            }
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedImage ?? image
        }.value
    }
    
    
    func deletePhoto(url: String) async throws {
        // Create a reference to the Firebase Storage
        let storageRef = Storage.storage(url: "gs://sync-69d00.firebasestorage.app").reference()
        
        // Extract the image path from the download URL
        guard let urlComponents = URLComponents(string: url),
              let imagePath = urlComponents.path.components(separatedBy: "/images/").last else {
            print("Invalid URL format")
            return
        }
        
        // Construct the full path in Firebase Storage
        let fullPath = "images/\(imagePath)"
        let fileRef = storageRef.child(fullPath)
        
        // Delete the file
        try await fileRef.delete()
        print("Successfully deleted image from storage: \(url)")
    }
}
