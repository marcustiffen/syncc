import Combine
import Foundation
import FirebaseFirestore


class ChatRoomsManager: ObservableObject {
    @Published private(set) var chatRooms: [ChatRoom] = []
    @Published private(set) var userCache: [String: DBUser] = [:] // Cache for user data
    
    @Published private(set) var unreadCounts: [String: Int] = [:]
    
    private let db = Firestore.firestore()
    private var chatRoomsListener: ListenerRegistration?
    private var isListening = false
    private var currentUserId: String?
    
    private func chatRoomsCollection() -> CollectionReference {
        db.collection("chatRooms")
    }
    
    // NEW: Track MessagesManager instances
    private var messagesManagers: [String: MessagesManager] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    // NEW: Computed property for total unread messages
    var totalUnreadMessages: Int {
        return unreadCounts.values.reduce(0, +)
    }
    

    func startListening(for userId: String) {
        guard !isListening || currentUserId != userId else { return }
        
        stopListening()
        
        currentUserId = userId
        isListening = true
        
        print("Starting Firestore listener for user: \(userId)")
        
        chatRoomsListener = chatRoomsCollection()
            .whereField("users", arrayContains: userId)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error listening to chat rooms: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No chat room documents found")
                    return
                }
                
                let chatRooms = documents.compactMap { document -> ChatRoom? in
                    do {
                        var chatRoom = try document.data(as: ChatRoom.self)
                        chatRoom.id = document.documentID
                        return chatRoom
                    } catch {
                        print("Error decoding chat room: \(error)")
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    self.chatRooms = chatRooms.sorted { $0.createdAt > $1.createdAt }
                    
                    // NEW: Create MessagesManagers for all chat rooms
                    self.createMessagesManagers(for: chatRooms, userId: userId)
                }
                
                // Pre-fetch user data for all chat rooms
                Task {
                    await self.prefetchUserData(for: chatRooms, currentUserId: userId)
                }
            }
    }
    
    // NEW: Create and manage MessagesManager instances for all chat rooms
    private func createMessagesManagers(for chatRooms: [ChatRoom], userId: String) {
        let currentChatRoomIds = Set(chatRooms.map { $0.id })
        let existingChatRoomIds = Set(messagesManagers.keys)
        
        // Remove managers for chat rooms that no longer exist
        let toRemove = existingChatRoomIds.subtracting(currentChatRoomIds)
        for chatRoomId in toRemove {
            messagesManagers[chatRoomId]?.removeListener()
            messagesManagers.removeValue(forKey: chatRoomId)
            unreadCounts.removeValue(forKey: chatRoomId)
        }
        
        // Add managers for new chat rooms
        let toAdd = currentChatRoomIds.subtracting(existingChatRoomIds)
        for chatRoomId in toAdd {
            let messagesManager = MessagesManager(chatRoomId: chatRoomId)
            messagesManagers[chatRoomId] = messagesManager
            
            // Subscribe to messages changes
            messagesManager.$messages
                .sink { [weak self] messages in
                    self?.updateUnreadCount(for: chatRoomId, messages: messages, userId: userId)
                }
                .store(in: &cancellables)
        }
    }
    
    // NEW: Update unread count for a specific chat room
    private func updateUnreadCount(for chatRoomId: String, messages: [Message], userId: String) {
        let unreadCount = messages.filter { message in
            !message.seen && message.senderId != userId
        }.count
        
        DispatchQueue.main.async {
            self.unreadCounts[chatRoomId] = unreadCount
        }
    }
    
    // Pre-fetch and cache user data
    private func prefetchUserData(for chatRooms: [ChatRoom], currentUserId: String) async {
        let allUserIds = Set(chatRooms.flatMap { $0.users }).subtracting([currentUserId])
        
        for userId in allUserIds {
            // Skip if already cached
            guard userCache[userId] == nil else { continue }
            
            do {
                let user = try await DBUserManager.shared.getUser(uid: userId)
                await MainActor.run {
                    userCache[userId] = user
                }
            } catch {
                print("Error fetching user \(userId): \(error)")
            }
        }
    }
    
    // Get cached user data
    func getUser(for userId: String) -> DBUser? {
        return userCache[userId]
    }
    
    // Get other user in a chat room
    func getOtherUser(in chatRoom: ChatRoom, currentUserId: String) -> DBUser? {
        let otherUserId = chatRoom.users.first { $0 != currentUserId }
        guard let otherUserId = otherUserId else { return nil }
        return userCache[otherUserId]
    }
    
    // Stop listening and clean up
    func stopListening() {
        chatRoomsListener?.remove()
        chatRoomsListener = nil
        isListening = false
        currentUserId = nil
        
        // Clean up all message managers
                for (_, manager) in messagesManagers {
                    manager.removeListener()
                }
        // NEW: Clean up message managers and cancellables
        messagesManagers.removeAll()
        unreadCounts.removeAll()
        cancellables.removeAll()
        print("Stopped Firestore listener")
    }
    
    // Clean up when deinitializing
    deinit {
        stopListening()
    }
}


extension ChatRoomsManager {
    func registerMessagesManager(_ manager: MessagesManager, for chatRoomId: String) {
        messagesManagers[chatRoomId] = manager
        
        // Subscribe to messages changes to update unread count
        manager.$messages
            .sink { [weak self] messages in
                self?.updateUnreadCount(for: chatRoomId, messages: messages)
            }
            .store(in: &cancellables)
    }
    
    // NEW: Unregister a MessagesManager
    func unregisterMessagesManager(for chatRoomId: String) {
        messagesManagers.removeValue(forKey: chatRoomId)
        unreadCounts.removeValue(forKey: chatRoomId)
    }
    
    // NEW: Update unread count for a specific chat room
    private func updateUnreadCount(for chatRoomId: String, messages: [Message]) {
        guard let currentUserId = currentUserId else { return }
        
        let unreadCount = messages.filter { message in
            !message.seen && message.senderId != currentUserId
        }.count
        
        DispatchQueue.main.async {
            self.unreadCounts[chatRoomId] = unreadCount
        }
    }
    
    // NEW: Mark messages as seen for a chat room
    func markMessagesAsSeen(for chatRoomId: String) {
        // This will be called when user opens a chat room
        // The MessagesManager will handle the actual Firestore update
        // This just updates our local count immediately for better UX
        DispatchQueue.main.async {
            self.unreadCounts[chatRoomId] = 0
        }
    }
}
