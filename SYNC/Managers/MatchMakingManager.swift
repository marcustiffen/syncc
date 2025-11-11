import Foundation
import Firebase
import SwiftUI



class MatchMakingManager: ObservableObject {
    
    static let shared = MatchMakingManager()
        
    let db = Firestore.firestore()
    
    // Rate limiting
    private var lastLikeTime: Date = Date.distantPast
    private let minLikeInterval: TimeInterval = 0.5
    
    private func usersCollection() -> CollectionReference {
        db.collection("users")
    }
    
    private func likesSentCollection(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("likes_sent")
    }
    
    private func likesReceivedCollection(uid: String) -> CollectionReference {
        db.collection("users").document(uid).collection("likes_received")
    }
    
    // MARK: - Modern async/await API
    
    func sendLike(currentUserId: String, likedUserId: String, isSubscriptionActive: Bool) async throws {
        // Rate limiting check
        let now = Date()
        if now.timeIntervalSince(lastLikeTime) < minLikeInterval {
            throw MatchMakingError.rateLimited
        }
        lastLikeTime = now
        
        if isSubscriptionActive {
            try await sendUnlimitedLike(currentUserId: currentUserId, likedUserId: likedUserId)
        } else {
            try await sendFreeLike(currentUserId: currentUserId, likedUserId: likedUserId)
        }
    }
    
    private func sendUnlimitedLike(currentUserId: String, likedUserId: String) async throws {
        print("Unlimited like sent")
        
        #if STAGING
        guard let url = URL(string: "https://us-central1-syncc-staging.cloudfunctions.net/sendLike") else {
            throw MatchMakingError.networkError("Invalid URL")
        }
        #else
        guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/sendLike") else {
            throw MatchMakingError.networkError("Invalid URL")
        }
        #endif
        
        let parameters: [String: Any] = [
            "currentUserId": currentUserId,
            "likedUserId": likedUserId
        ]
        
        try await performNetworkRequest(url: url, parameters: parameters)
    }
    
    private func sendFreeLike(currentUserId: String, likedUserId: String) async throws {
        print("Free like sent")
        #if STAGING
        guard let url = URL(string: "https://us-central1-syncc-staging.cloudfunctions.net/sendLikeFree") else {
            throw MatchMakingError.networkError("Invalid URL")
        }
        #else
        guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/sendLikeFree") else {
            throw MatchMakingError.networkError("Invalid URL")
        }
        #endif
        
        let parameters: [String: Any] = [
            "currentUserId": currentUserId,
            "likedUserId": likedUserId
        ]
        
        do {
            try await performNetworkRequest(url: url, parameters: parameters)
        } catch {
            // For free users, assume subscription errors mean they hit their limit
            if error.localizedDescription.contains("limit") || error.localizedDescription.contains("subscription") {
                throw MatchMakingError.subscriptionRequired
            }
            throw error
        }
    }
    
    private func performNetworkRequest(url: URL, parameters: [String: Any]) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            throw MatchMakingError.networkError("Failed to serialize request")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MatchMakingError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                
                // Check for specific error types
                if httpResponse.statusCode == 402 || errorMessage.contains("subscription") {
                    throw MatchMakingError.subscriptionRequired
                } else if httpResponse.statusCode == 429 {
                    throw MatchMakingError.rateLimited
                } else {
                    throw MatchMakingError.networkError(errorMessage)
                }
            }
            
            print("Network request successful")
        } catch {
            if error is MatchMakingError {
                throw error
            } else {
                throw MatchMakingError.networkError(error.localizedDescription)
            }
        }
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
    
    func unmatchUser(currentUserId: String, unmatchedUserId: String) async throws {
        #if STAGING
        guard let url = URL(string: "https://us-central1-syncc-staging.cloudfunctions.net/unmatchUser") else {
            throw MatchMakingError.networkError("Invalid URL")
        }
        #else
        guard let url = URL(string: "https://us-central1-sync-69d00.cloudfunctions.net/unmatchUser") else {
            throw MatchMakingError.networkError("Invalid URL")
        }
        #endif
        
        let parameters: [String: Any] = [
            "currentUserId": currentUserId,
            "unmatchedUserId": unmatchedUserId
        ]
        
        try await performNetworkRequest(url: url, parameters: parameters)
    }
    
    // MARK: - Legacy callback-based API (for backward compatibility)
    
    func sendLike(currentUserId: String, likedUserId: String, isSubscriptionActive: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                try await sendLike(currentUserId: currentUserId, likedUserId: likedUserId, isSubscriptionActive: isSubscriptionActive)
                await MainActor.run {
                    completion(.success("Success"))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func unmatchUser(currentUserId: String, unmatchedUserId: String, completion: @escaping (Result<String, Error>) -> Void) {
        Task {
            do {
                try await unmatchUser(currentUserId: currentUserId, unmatchedUserId: unmatchedUserId)
                await MainActor.run {
                    completion(.success("Success"))
                }
            } catch {
                await MainActor.run {
                    completion(.failure(error))
                }
            }
        }
    }
}



// Custom errors for better error handling
enum MatchMakingError: LocalizedError {
    case subscriptionRequired
    case networkError(String)
    case invalidResponse
    case rateLimited
    
    var errorDescription: String? {
        switch self {
        case .subscriptionRequired:
            return "Subscription required to continue liking users"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimited:
            return "Too many requests. Please wait a moment."
        }
    }
}
