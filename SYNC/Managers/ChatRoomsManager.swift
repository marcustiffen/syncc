import Combine
import Foundation
import FirebaseFirestore


class ChatRoomsManager: ObservableObject {
    @Published private(set) var chatRooms: [ChatRoom] = []
        
    private let db = Firestore.firestore()
    
    private var chatRoomsListener: ListenerRegistration? = nil
    private var chatRoomCancellables = Set<AnyCancellable>()
    private var listenerRegistered = false  // Track if the listener is already registered
    
    
    private func chatRoomsCollection() -> CollectionReference {
        db.collection("chatRooms")
    }
    
    
    func addListenerChatRooms(userId: String) {
        guard !listenerRegistered else { return }  // Ensure listener is added only once
        listenerRegistered = true  // Mark listener as registered
        
        getChatRooms(uid: userId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error in chatrooms listener: \(error)")
                }
            } receiveValue: { [weak self] chatrooms in
                self?.chatRooms = chatrooms
            }
            .store(in: &chatRoomCancellables)
    }
    
    func getChatRooms(uid: String) -> AnyPublisher<[ChatRoom], any Error> {
        let chatRoomsCollection = chatRoomsCollection().whereField("users", arrayContains: uid)
        let (publisher, listener) = chatRoomsCollection.addSnapShotListener(as: ChatRoom.self)
        self.chatRoomsListener = listener
        return publisher
    }
    
    
    func removeListener() {
        if !chatRoomCancellables.isEmpty {
            chatRoomsListener?.remove()
            chatRoomCancellables.removeAll()
            listenerRegistered = false
        }
    }
}



struct ChatRoom: Identifiable, Codable {
    var id: String = ""
    var users: [String]
    var createdAt: Date
    
    init(users: [String], createdAt: Date) {
        self.users = users
        self.createdAt = createdAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.users = try container.decode([String].self, forKey: .users)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    enum CodingKeys: CodingKey {
        case id
        case users
        case createdAt
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.users, forKey: .users)
        try container.encode(self.createdAt, forKey: .createdAt)
    }
}
