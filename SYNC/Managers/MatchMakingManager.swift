import Foundation
import Firebase
import SwiftUI


class MatchMakingManager: ObservableObject {
    
    static let shared = MatchMakingManager()
        
    let db = Firestore.firestore()
    
    private func usersCollection() -> CollectionReference {
        db.collection("users")
    }
    
    private func likesSentCollection(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("likes_sent")
    }
    
    private func likesReceivedCollection(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("likes_received")
    }
    
    //MARK: Do not delete this function ever, it works a dream
//    func sendLike(currentUserId: String, likedUserId: String, completion: @escaping (Result<String, Error>) -> Void) {
//        do {
//            // The Cloud Function URL
//            guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/sendLike") else {
//                print("Invalid URL.")
//                return
//            }
//            
//            // Prepare the request
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            
//            // Add the parameters
//            let parameters: [String: Any] = [
//                "currentUserId": currentUserId,
//                "likedUserId": likedUserId
//            ]
//            
//            do {
//                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
//            } catch {
//                print("Error serializing JSON: \(error)")
//                return
//            }
//            
//            // Send the request
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                if let error = error {
//                    DispatchQueue.main.async {
//                        completion(.failure(error))
//                    }
//                    return
//                }
//                
//                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
//                    DispatchQueue.main.async {
//                        completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
//                    }
//                    return
//                }
//                
//                // Parse the response
//                if let resultString = String(data: data, encoding: .utf8) {
//                    DispatchQueue.main.async {
//                        completion(.success(resultString))
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        completion(.failure(NSError(domain: "Data parsing error", code: 0, userInfo: nil)))
//                    }
//                }
//            }.resume()
//        }
//    }
    
    
    func sendLike(currentUserId: String, likedUserId: String, isSubscriptionActive: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        if isSubscriptionActive {
            unlimitedLikesFunction(currentUserId: currentUserId, likedUserId: likedUserId, completion: completion)
        } else {
            nonSubscribedLikeFunction(currentUserId: currentUserId, likedUserId: likedUserId, completion: completion)
        }
    }
    
    private func unlimitedLikesFunction(currentUserId: String, likedUserId: String, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            // The Cloud Function URL
            guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/sendLike") else {
                print("Invalid URL.")
                return
            }
            
            // Prepare the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Add the parameters
            let parameters: [String: Any] = [
                "currentUserId": currentUserId,
                "likedUserId": likedUserId
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print("Error serializing JSON: \(error)")
                return
            }
            
            // Send the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                    }
                    return
                }
                
                // Parse the response
                if let resultString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        completion(.success(resultString))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Data parsing error", code: 0, userInfo: nil)))
                    }
                }
            }.resume()
        }
    }
    
    
    private func nonSubscribedLikeFunction(currentUserId: String, likedUserId: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/sendLikeFree") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "currentUserId": currentUserId,
            "likedUserId": likedUserId
        ]
        
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
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            if let resultString = String(data: data, encoding: .utf8) {
                completion(.success(resultString))
            } else {
                completion(.failure(NSError(domain: "Data parsing error", code: 0, userInfo: nil)))
            }
        }.resume()
    }
    
    
    func dismissUser(currentUserId: String, dismissedUserId: String) async {
        do {
            try await usersCollection()
                .document(currentUserId)
                .collection("dismissed_users")
                .document(dismissedUserId)
                .setData([
                    "timestamp": Timestamp(),
                    "userId": dismissedUserId
                ])
            
            try await likesReceivedCollection(uid: currentUserId)
                .document(dismissedUserId)
                .delete()
            
            print("User dismissed successfully.")
        } catch {
            print("Error dismissing user: \(error.localizedDescription)")
        }
    }
    
    func unmatchUser(currentUserId: String, unmatchedUserId: String, completion: @escaping (Result<String, Error>) -> Void) {
        do {
            // The Cloud Function URL
            guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/unmatchUser") else {
                print("Invalid URL.")
                return
            }
            
            // Prepare the request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            // Add the parameters
            let parameters: [String: Any] = [
                "currentUserId": currentUserId,
                "unmatchedUserId": unmatchedUserId
            ]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print("Error serializing JSON: \(error)")
                return
            }
            
            // Send the request
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                    }
                    return
                }
                
                // Parse the response
                if let resultString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        completion(.success(resultString))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Data parsing error", code: 0, userInfo: nil)))
                    }
                }
            }.resume()
        }
    }
}
