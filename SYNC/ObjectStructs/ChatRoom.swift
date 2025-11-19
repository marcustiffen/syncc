import Foundation


struct /*Group*/ChatRoom: Identifiable, Codable {
    var id: String = ""
    var name: String
    var users: [String]
    var createdAt: Date
    
    init(name: String, users: [String], createdAt: Date) {
        self.name = name
        self.users = users
        self.createdAt = createdAt
    }
    
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case users
        case createdAt
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
