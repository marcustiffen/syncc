
import Foundation


//struct FitnessType: Identifiable, Codable, Equatable {
//    var id: String
//    var name: String
//    var emoji: String
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, emoji
//    }
//    
//    init(id: String = "Unknown", name: String = "Unknown", emoji: String = "Unkown") {
//        self.id = id
//        self.name = name
//        self.emoji = emoji
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "Unknown"
//        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown"
//        emoji = try container.decodeIfPresent(String.self, forKey: .emoji) ?? "Unknown"
//    }
//}




enum StandardFitnessType: String, CaseIterable, Identifiable {
    case gym = "Gym"
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case yoga = "Yoga"
    case pilates = "Pilates"
    case crossfit = "CrossFit"
    case hiking = "Hiking"
    case walking = "Walking"
    case boxing = "Boxing"
    case martialArts = "Martial Arts"
    case homeWorkouts = "Home Workouts"
    case outdoorWorkouts = "Outdoor Workouts"
    case parkour = "Parkour"
    case rockClimbing = "Rock Climbing"
    case rowing = "Rowing"
    case dance = "Dance"
    case zumba = "Zumba"
    case weightlifting = "Weightlifting"
    case calisthenics = "Calisthenics"
    case aerobics = "Aerobics"
    case gymnastics = "Gymnastics"
    case taiChi = "Tai Chi"
    case meditation = "Meditation"
    case spinClass = "Spin Class"
    case barre = "Barre"
    case skiing = "Skiing"
    case snowboarding = "Snowboarding"
    case surfing = "Surfing"
    case paddleboarding = "Paddleboarding"
    case kayaking = "Kayaking"
    case sailing = "Sailing"
    case horsebackRiding = "Horseback Riding"
    case archery = "Archery"
    case skating = "Skating"
    case fencing = "Fencing"
    case circuitTraining = "Circuit Training"
    case triathlon = "Triathlon"
    case diving = "Diving"
    case obstacleCourses = "Obstacle Courses"
    case bootcamp = "Bootcamp"
    case frisbee = "Frisbee"
    case golf = "Golf"
    case tennis = "Tennis"
    case badminton = "Badminton"
    case cricket = "Cricket"
    case rugby = "Rugby"
    case basketball = "Basketball"
    case padel = "Padel"
    case hyrox = "Hyrox"

    var id: String { self.rawValue }
}



struct FitnessTypeHelper {
    static let emojiForId: [String: String] = [
        "Gym": "🏋️‍♂️",
        "Running": "🏃",
        "Cycling": "🚴",
        "Swimming": "🏊",
        "Yoga": "🧘",
        "Pilates": "🩰",
        "CrossFit": "🔥",
        "Hiking": "🥾",
        "Walking": "🚶",
        "Boxing": "🥊",
        "Martial Arts": "🥋",
        "Home Workouts": "🏠",
        "Outdoor Workouts": "🌳",
        "Parkour": "🤸‍♂️",
        "Rock Climbing": "🧗",
        "Rowing": "🚣",
        "Dance": "💃",
        "Zumba": "🕺",
        "Weightlifting": "🏋️",
        "Calisthenics": "🤸",
        "Aerobics": "🏃",
        "Gymnastics": "🤸‍♀️",
        "Tai Chi": "🧘‍♂️",
        "Meditation": "🧘‍♀️",
        "Spin Class": "🚴‍♀️",
        "Barre": "🩰",
        "Skiing": "⛷️",
        "Snowboarding": "🏂",
        "Surfing": "🏄",
        "Paddleboarding": "🏄‍♀️",
        "Kayaking": "🛶",
        "Sailing": "⛵",
        "Horseback Riding": "🏇",
        "Archery": "🏹",
        "Skating": "⛸️",
        "Fencing": "🤺",
        "Circuit Training": "🏋️‍♀️",
        "Triathlon": "🏊‍♀️",
        "Diving": "🤿",
        "Obstacle Courses": "🔗",
        "Bootcamp": "🏕️",
        "Frisbee": "🥏",
        "Golf": "⛳",
        "Tennis": "🎾",
        "Badminton": "🏸",
        "Cricket": "🏏",
        "Rugby": "🏉",
        "Basketball": "🏀",
        "Padel": "🎾",
        "Hyrox": "🏃"
    ]
    
    static func emoji(for id: String) -> String {
        emojiForId[id] ?? "❓"
    }
}



