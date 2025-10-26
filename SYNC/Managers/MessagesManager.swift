import Combine
import Foundation
import FirebaseFirestore



class MessagesManager: ObservableObject {
    @Published var messages: [Message] = []
    
    private let db = Firestore.firestore()
    private var messagesCancellables = Set<AnyCancellable>()
    private var messagesListener: ListenerRegistration?
    
    // The chat room ID this manager is responsible for
    private let chatRoomId: String
    
    // Initialize with a specific chat room ID
    init(chatRoomId: String) {
        self.chatRoomId = chatRoomId
        startListening()
    }
    
    deinit {
        removeListener()
    }
    
    private func chatRoomCollection() -> CollectionReference {
        db.collection("chatRooms")
    }
    
    private func messagesCollection() -> CollectionReference {
        chatRoomCollection().document(chatRoomId).collection("messages")
    }
    
    private func startListening() {
        getMessages()
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error in chat room listener: \(error)")
                }
            } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &messagesCancellables)
    }
    
    private func getMessages() -> AnyPublisher<[Message], any Error> {
        let chatRoomMessagesCollection = messagesCollection().order(by: "timestamp")
        let (publisher, listener) = chatRoomMessagesCollection.addSnapShotListener(as: Message.self)
        self.messagesListener = listener
        return publisher
    }
    
    func removeListener() {
        messagesListener?.remove()
        messagesCancellables.removeAll()
    }
    
    func makeMessagesSeen(receivedMessages: [Message]) {
        for message in receivedMessages {
            let messageRef = messagesCollection().document(message.id)
            messageRef.updateData(["seen": true])
        }
    }
    
    // Send a message to this chat room
    func sendMessage(text: String, messageSender: DBUser, messageReceiver: DBUser) {
        do {
            let newMessage = Message(
                id: "\(UUID())",
                text: text,
                senderId: messageSender.uid,
                timestamp: Date(),
                seen: false
            )
            
            try messagesCollection()
                .document(newMessage.id)
                .setData(from: newMessage)
            
            NotificationManager.shared.sendSingularPushNotification(token: messageReceiver.fcmToken!, message: text, title: messageSender.name!) { result in
                switch result {
                case .success(let success):
                    if success {
                        print("Notification sent successfully")
                    } else {
                        print("Failed to send notification")
                    }
                case .failure(let error):
                    print("Failed to send notification: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    func markAllReceivedMessagesAsSeen(currentUserId: String) {
        let receivedMessages = messages.filter { message in
            !message.seen && message.senderId != currentUserId
        }
        
        if !receivedMessages.isEmpty {
            makeMessagesSeen(receivedMessages: receivedMessages)
        }
    }
}

