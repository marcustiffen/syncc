import Combine
import Foundation
import FirebaseFirestore



//class MessagesManager: ObservableObject {
//    @Published var messages: [Message] = []
//    
//    private let db = Firestore.firestore()
//    private var messagesCancellables = Set<AnyCancellable>()
//    private var messagesListener: ListenerRegistration?
//    
//    // The chat room ID this manager is responsible for
//    private let chatRoomId: String
//    
//    // Initialize with a specific chat room ID
//    init(chatRoomId: String) {
//        self.chatRoomId = chatRoomId
//        startListening()
//    }
//    
//    deinit {
//        removeListener()
//    }
//    
//    private func chatRoomCollection() -> CollectionReference {
//        db.collection("chatRooms")
//    }
//    
//    private func messagesCollection() -> CollectionReference {
//        chatRoomCollection().document(chatRoomId).collection("messages")
//    }
//    
//    private func startListening() {
//        getMessages()
//            .sink { completion in
//                if case .failure(let error) = completion {
//                    print("Error in chat room listener: \(error)")
//                }
//            } receiveValue: { [weak self] messages in
//                self?.messages = messages
//            }
//            .store(in: &messagesCancellables)
//    }
//    
//    private func getMessages() -> AnyPublisher<[Message], any Error> {
//        let chatRoomMessagesCollection = messagesCollection().order(by: "timestamp")
//        let (publisher, listener) = chatRoomMessagesCollection.addSnapShotListener(as: Message.self)
//        self.messagesListener = listener
//        return publisher
//    }
//    
//    func removeListener() {
//        messagesListener?.remove()
//        messagesCancellables.removeAll()
//    }
//    
//    func makeMessagesSeen(receivedMessages: [Message]) {
//        for message in receivedMessages {
//            let messageRef = messagesCollection().document(message.id)
//            messageRef.updateData(["seen": true])
//        }
//    }
//    
//    // Send a message to this chat room
//    func sendMessage(text: String, messageSender: DBUser, messageReceiver: DBUser) {
//        do {
//            let newMessage = Message(
//                id: "\(UUID())",
//                text: text,
//                senderId: messageSender.uid,
//                timestamp: Date(),
//                seen: false
//            )
//            
//            try messagesCollection()
//                .document(newMessage.id)
//                .setData(from: newMessage)
//            
//            NotificationManager.shared.sendSingularPushNotification(token: messageReceiver.fcmToken!, message: text, title: messageSender.name!) { result in
//                switch result {
//                case .success(let success):
//                    if success {
//                        print("Notification sent successfully")
//                    } else {
//                        print("Failed to send notification")
//                    }
//                case .failure(let error):
//                    print("Failed to send notification: \(error.localizedDescription)")
//                }
//            }
//        } catch {
//            print("Error sending message: \(error.localizedDescription)")
//        }
//    }
//    
//    func markAllReceivedMessagesAsSeen(currentUserId: String) {
//        let receivedMessages = messages.filter { message in
//            !message.seen && message.senderId != currentUserId
//        }
//        
//        if !receivedMessages.isEmpty {
//            makeMessagesSeen(receivedMessages: receivedMessages)
//        }
//    }
//}




class MessagesManager: ObservableObject {
    @Published var messages: [Message] = []
    
    private let db = Firestore.firestore()
    private var messagesCancellables = Set<AnyCancellable>()
    private var messagesListener: ListenerRegistration?
    private let chatRoomId: String
    
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
    
    func sendMessage(text: String, messageSender: DBUser, messageReceiver: DBUser) {
        do {
            let newMessage = Message(
                id: "\(UUID())",
                text: text,
                senderId: messageSender.uid,
                timestamp: Date(),
                seen: false
            )
            
            // Send the message
            try messagesCollection()
                .document(newMessage.id)
                .setData(from: newMessage)
            
            // NEW: Update chatroom metadata (this will gradually add fields to existing chatrooms)
            updateChatRoomMetadata(
                lastMessageText: text,
                lastMessageSenderId: messageSender.uid,
                timestamp: newMessage.timestamp
            )
            
            // Send notification
            if let token = messageReceiver.fcmToken, let senderName = messageSender.name {
                NotificationManager.shared.sendSingularPushNotification(
                    token: token,
                    message: text,
                    title: senderName
                ) { result in
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
            }
        } catch {
            print("Error sending message: \(error.localizedDescription)")
        }
    }
    
    // NEW: Update chatroom metadata (adds new fields without breaking existing data)
    private func updateChatRoomMetadata(lastMessageText: String, lastMessageSenderId: String, timestamp: Date) {
        let chatRoomRef = chatRoomCollection().document(chatRoomId)
        
        // This will add the new fields to existing chatrooms or update them
        chatRoomRef.updateData([
            "lastMessageAt": Timestamp(date: timestamp),
            "lastMessageText": lastMessageText,
            "lastMessageSenderId": lastMessageSenderId
        ]) { error in
            if let error = error {
                print("Error updating chatroom metadata: \(error.localizedDescription)")
            } else {
                print("✅ Chatroom metadata updated for sorting")
            }
        }
    }
    
    func markAllReceivedMessagesAsSeen(currentUserId: String) {
        let receivedMessages = messages.filter { message in
            !message.seen && message.senderId != currentUserId
        }.count
        
        if receivedMessages > 0 {
            let messagesToMark = messages.filter { message in
                !message.seen && message.senderId != currentUserId
            }
            makeMessagesSeen(receivedMessages: messagesToMark)
        }
    }
}
