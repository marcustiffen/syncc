import Foundation


struct Activity: Identifiable, Codable {
    var id: String
    var creatorId: String
    var name: String
    var description: String?
    var location: DBLocation?
    var startTime: Date
    var createdAt: Date
    var participants: [String]?
    var nonParticipants: [String]?
    var status: String // Upcoming, Completed, Canceled
    
    var upvotes: Int?
    var downvotes: Int?
    
    var maxParticipants: Int?
    
    
    init(id: String, creatorId: String, name: String, description: String? = nil, location: DBLocation? = nil, startTime: Date, createdAt: Date, participants: [String]? = nil, nonParticipants: [String]? = nil, status: String, upvotes: Int? = nil, downvotes: Int? = nil, maxParticipants: Int? = nil) {
        self.id = id
        self.creatorId = creatorId
        self.name = name
        self.description = description
        self.location = location
        self.startTime = startTime
        self.createdAt = createdAt
        self.participants = participants
        self.nonParticipants = nonParticipants
        self.status = status
        self.upvotes = upvotes
        self.downvotes = downvotes
        self.maxParticipants = maxParticipants
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorId
        case name
        case description
        case location
        case startTime
        case createdAt
        case participants
        case nonParticipants
        case status
        case upvotes
        case downvotes
        case maxParticipants
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.creatorId = try container.decode(String.self, forKey: .creatorId)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.location = try container.decodeIfPresent(DBLocation.self, forKey: .location)
        self.startTime = try container.decode(Date.self, forKey: .startTime)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.participants = try container.decodeIfPresent([String].self, forKey: .participants)
        self.nonParticipants = try container.decodeIfPresent([String].self, forKey: .nonParticipants)
        self.status = try container.decode(String.self, forKey: .status)
        self.upvotes = try container.decodeIfPresent(Int.self, forKey: .upvotes)
        self.downvotes = try container.decodeIfPresent(Int.self, forKey: .downvotes)
        self.maxParticipants = try container.decodeIfPresent(Int.self, forKey: .maxParticipants)
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.creatorId, forKey: .creatorId)
        try container.encode(self.name, forKey: .name)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.location, forKey: .location)
        try container.encodeIfPresent(self.startTime, forKey: .startTime)
        try container.encode(self.createdAt, forKey: .createdAt)
        try container.encodeIfPresent(self.participants, forKey: .participants)
        try container.encodeIfPresent(self.nonParticipants, forKey: .nonParticipants)
        try container.encode(self.status, forKey: .status)
        try container.encodeIfPresent(self.upvotes, forKey: .upvotes)
        try container.encodeIfPresent(self.downvotes, forKey: .downvotes)
        try container.encodeIfPresent(self.maxParticipants, forKey: .maxParticipants)
    }
}


extension Activity: Equatable {
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}
