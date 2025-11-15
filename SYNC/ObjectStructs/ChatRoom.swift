//import Foundation
//
//
//struct ChatRoom: Identifiable, Codable {
//    var id: String = ""
//    var users: [String]
//    var createdAt: Date
//    
//    init(users: [String], createdAt: Date) {
//        self.users = users
//        self.createdAt = createdAt
//    }
//    
//    init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
//        self.users = try container.decode([String].self, forKey: .users)
//        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
//    }
//    
//    enum CodingKeys: CodingKey {
//        case id
//        case users
//        case createdAt
//    }
//    
//    func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(self.id, forKey: .id)
//        try container.encode(self.users, forKey: .users)
//        try container.encode(self.createdAt, forKey: .createdAt)
//    }
//}
