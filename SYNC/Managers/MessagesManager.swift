import Combine
import Foundation
import FirebaseFirestore


class MessagesManager: ObservableObject {
        
    static let shared = MessagesManager()
    
    @Published /*private(set) */var messages: [Message] = []
    @Published var otherUser: DBUser? = nil
    
    private let db = Firestore.firestore()
    
    private var messagesCancellables = Set<AnyCancellable>()
    
    private var messagesListener: ListenerRegistration? = nil
    
    private func chatRoomCollection() -> CollectionReference {
        db.collection("chatRooms")
    }
    
    private func messagesCollection(chatRoomId: String) -> CollectionReference {
        chatRoomCollection().document(chatRoomId).collection("messages")
    }
    
    
    func addListenerForChatRoom(chatRoomId: String) {
        getMessages(for: chatRoomId) // Use the new method
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error in chat room listener: \(error)")
                }
            } receiveValue: { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &messagesCancellables)
    }
    
    
    func getMessages(for chatRoomId: String) -> AnyPublisher<[Message], any Error> {
        let chatRoomMessagesCollection = messagesCollection(chatRoomId: chatRoomId).order(by: "timestamp")
        let (publisher, listener) = chatRoomMessagesCollection.addSnapShotListener(as: Message.self)
        self.messagesListener = listener
        return publisher
    }
    
    
    func removeListener() {
        if !messagesCancellables.isEmpty {
            messagesListener?.remove()
            messagesCancellables.removeAll()
        }
    }
    
    
    func makeMessagesSeen(receivedMessages: [Message], chatRoomId: String) {        
        for message in receivedMessages {
            let messageRef = messagesCollection(chatRoomId: chatRoomId).document(message.id)
            messageRef.updateData(["seen": true])
        }
    }
    
    
    // Send a message to a specific chat room
    func sendMessage(to chatRoomId: String, text: String, messageSender: DBUser, messageReceiver: DBUser) {
        do {
            let newMessage = Message(
                id: "\(UUID())",
                text: text,
                senderId: messageSender.uid,
                timestamp: Date(),
                seen: false
            )
            
            //            try db.collection("chatRooms")
            //                .document(chatRoomId)
            //                .collection("messages")
            //                .document(newMessage.id)
            //                .setData(from: newMessage)
            try messagesCollection(chatRoomId: chatRoomId)
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
}


