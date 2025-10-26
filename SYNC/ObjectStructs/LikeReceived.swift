import Foundation

struct LikeReceived: Codable, Equatable {
    var userId: String
    var timestamp: Date
    
    init(timestamp: Date, userId: String) {
        self.timestamp = timestamp
        self.userId = userId
    }
    
    enum CodingKeys: CodingKey {
        case timestamp
        case userId
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.timestamp = try container.decode(Date.self, forKey: .timestamp)
        self.userId = try container.decode(String.self, forKey: .userId)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(userId, forKey: .userId)
    }
}
