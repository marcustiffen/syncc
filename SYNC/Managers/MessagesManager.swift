import Combine
import Foundation
import FirebaseFirestore

class MessagesManager: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var hasMoreMessages = true
    
    private let db = Firestore.firestore()
    private var messagesCancellables = Set<AnyCancellable>()
    private var messagesListener: ListenerRegistration?
    private let chatRoomId: String
    
    // Pagination
    private var lastDocument: DocumentSnapshot?
    private let pageSize = 50
    
    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        startListening()
    }
    
    deinit {
        removeListener()
    }
    
    // MARK: - Firestore References
    private func chatRoomCollection() -> CollectionReference {
        db.collection("chatRooms")
    }
    
    private func messagesCollection() -> CollectionReference {
        chatRoomCollection().document(chatRoomId).collection("messages")
    }
    
    // MARK: - Real-time Listener
    private func startListening() {
        getMessages()
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ Error in chat room listener: \(error)")
                }
            } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &messagesCancellables)
    }
    
    private func getMessages() -> AnyPublisher<[Message], any Error> {
        let chatRoomMessagesCollection = messagesCollection()
            .order(by: "timestamp", descending: false)
        
        let (publisher, listener) = chatRoomMessagesCollection.addSnapShotListener(as: Message.self)
        self.messagesListener = listener
        return publisher
    }
    
    // MARK: - Pagination (Optional - for large chat histories)
    func loadMoreMessages() {
        guard !isLoading && hasMoreMessages else { return }
        isLoading = true
        
        var query = messagesCollection()
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)
        
        if let lastDoc = lastDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                print("❌ Error loading more messages: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                self.hasMoreMessages = false
                return
            }
            
            self.lastDocument = documents.last
            
            let newMessages = documents.compactMap { doc -> Message? in
                try? doc.data(as: Message.self)
            }.reversed() // Reverse because we queried descending
            
            // Prepend to existing messages
            self.messages.insert(contentsOf: newMessages, at: 0)
            
            if documents.count < self.pageSize {
                self.hasMoreMessages = false
            }
        }
    }
    
    // MARK: - Cleanup
    func removeListener() {
        messagesListener?.remove()
        messagesCancellables.removeAll()
    }
    
    // MARK: - Mark Messages as Seen
    func makeMessagesSeen(receivedMessages: [Message]) {
        let batch = db.batch()
        
        for message in receivedMessages {
            let messageRef = messagesCollection().document(message.id)
            batch.updateData(["seen": true], forDocument: messageRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("❌ Error marking messages as seen: \(error)")
            } else {
                print("Marked \(receivedMessages.count) messages as seen")
            }
        }
    }
    
    // MARK: - Send Message
    func sendMessage(text: String, messageSender: DBUser, messageReceiver: DBUser) {
        do {
            let newMessage = Message(
                id: UUID().uuidString,
                text: text,
                senderId: messageSender.uid,
                timestamp: Date(),
                seen: false
            )
            
            // Send the message
            try messagesCollection()
                .document(newMessage.id)
                .setData(from: newMessage)
            
            // Update chatroom metadata for sorting in conversation list
            updateChatRoomMetadata(
                lastMessageText: text,
                lastMessageSenderId: messageSender.uid,
                timestamp: newMessage.timestamp
            )
            
            // Send push notification
            sendPushNotification(
                to: messageReceiver,
                from: messageSender,
                messageText: text
            )
            
            print("Message sent successfully")
        } catch {
            print("❌ Error sending message: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Update Chatroom Metadata
    private func updateChatRoomMetadata(
        lastMessageText: String,
        lastMessageSenderId: String,
        timestamp: Date
    ) {
        let chatRoomRef = chatRoomCollection().document(chatRoomId)
        
        chatRoomRef.updateData([
            "lastMessageAt": Timestamp(date: timestamp),
            "lastMessageText": lastMessageText,
            "lastMessageSenderId": lastMessageSenderId
        ]) { error in
            if let error = error {
                print("❌ Error updating chatroom metadata: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Push Notifications
    private func sendPushNotification(
        to receiver: DBUser,
        from sender: DBUser,
        messageText: String
    ) {
        guard let token = receiver.fcmToken,
              let senderName = sender.name else {
            print("⚠️ Missing FCM token or sender name")
            return
        }
        
        NotificationManager.shared.sendSingularPushNotification(
            token: token,
            message: messageText,
            title: senderName
        ) { result in
            switch result {
            case .success(let success):
                print(success ? "Notification sent" : "Notification failed")
            case .failure(let error):
                print("❌ Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Mark All Received Messages as Seen
    func markAllReceivedMessagesAsSeen(currentUserId: String) {
        let receivedMessages = messages.filter { message in
            !message.seen && message.senderId != currentUserId
        }
        
        if !receivedMessages.isEmpty {
            makeMessagesSeen(receivedMessages: receivedMessages)
        }
    }
}
