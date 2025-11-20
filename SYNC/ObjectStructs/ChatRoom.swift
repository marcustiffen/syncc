import Foundation


struct ChatRoom: Identifiable, Codable {
    var id: String = ""
    var name: String
    var users: [String]
    var createdAt: Date
    
    // NEW: Add these fields for sorting
    var lastMessageAt: Date?
    var lastMessageText: String?
    var lastMessageSenderId: String?
    var lastMessageSeenBy: [String]? // Array of user IDs who have seen it
    
    init(name: String, users: [String], createdAt: Date) {
        self.name = name
        self.users = users
        self.createdAt = createdAt
    }
    
    
//    enum CodingKeys: CodingKey {
//        case id
//        case name
//        case users
//        case createdAt
//    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case users
        case name
        case createdAt
        case lastMessageAt
        case lastMessageText
        case lastMessageSenderId
        case lastMessageSeenBy
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.users = try container.decode([String].self, forKey: .users)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.users, forKey: .users)
        try container.encode(self.createdAt, forKey: .createdAt)
    }
}
