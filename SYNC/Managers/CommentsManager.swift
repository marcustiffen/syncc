import Foundation
import FirebaseFirestore
import Combine

@MainActor
class CommentsManager: ObservableObject {
    @Published var comments: [Message] = []
    @Published var users: [String: DBUser] = [:] // Holds all users
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    private let activityId: String
    
    init(activityId: String) {
        self.activityId = activityId
    }
    
    // MARK: - Fetch Comments
    
    func startListening() {
        isLoading = true
        
        listener = db.collection("activities")
            .document(activityId)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to load comments: \(error.localizedDescription)"
                    print("Error fetching comments: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.comments = []
                    return
                }
                
                self.comments = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                
                // Fetch users for all comments
                Task {
                    await self.fetchUsers()
                }
            }
    }
    
    // MARK: - Fetch Users
    
    private func fetchUsers() async {
        let uniqueSenderIds = Set(comments.map { $0.senderId })
        
        for userId in uniqueSenderIds {
            // Skip if already loaded
            guard users[userId] == nil else { continue }
            
            do {
                let user = try await DBUserManager.shared.getUser(uid: userId)
                await MainActor.run {
                    users[userId] = user
                }
            } catch {
                print("Failed to load user \(userId): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Post Comment
    
    func postComment(text: String, userId: String) async throws {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw NSError(domain: "CommentsManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Comment cannot be empty"])
        }
        
        let comment = Message(
            id: UUID().uuidString,
            text: text,
            senderId: userId,
            timestamp: Date(),
            seen: false
        )
        
        try db.collection("activities")
            .document(activityId)
            .collection("comments")
            .document(comment.id)
            .setData(from: comment)
    }
    
    // MARK: - Delete Comment
    
    func deleteComment(commentId: String, userId: String) async throws {
        let commentDoc = try await db.collection("activities")
            .document(activityId)
            .collection("comments")
            .document(commentId)
            .getDocument()
        
        guard let comment = try? commentDoc.data(as: Message.self) else {
            throw NSError(domain: "CommentsManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Comment not found"])
        }
        
        guard comment.senderId == userId else {
            throw NSError(domain: "CommentsManager", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only delete your own comments"])
        }
        
        try await db.collection("activities")
            .document(activityId)
            .collection("comments")
            .document(commentId)
            .delete()
    }
    
    // MARK: - Stop Listening
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
