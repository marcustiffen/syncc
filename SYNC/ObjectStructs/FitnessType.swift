
import Foundation


struct FitnessType: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var emoji: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, emoji
    }
    
    init(id: String = "Unknown", name: String = "Unknown", emoji: String = "Unkown") {
        self.id = id
        self.name = name
        self.emoji = emoji
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "Unknown"
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Unknown"
        emoji = try container.decodeIfPresent(String.self, forKey: .emoji) ?? "Unknown"
    }
}

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
    var emoji: String {
        switch self {
        case .gym: return "🏋️‍♂️"
        case .running: return "🏃"
        case .cycling: return "🚴"
        case .swimming: return "🏊"
        case .yoga: return "🧘"
        case .pilates: return "🩰"
        case .crossfit: return "🔥"
        case .hiking: return "🥾"
        case .walking: return "🚶"
        case .boxing: return "🥊"
        case .martialArts: return "🥋"
        case .homeWorkouts: return "🏠"
        case .outdoorWorkouts: return "🌳"
        case .parkour: return "🤸‍♂️"
        case .rockClimbing: return "🧗"
        case .rowing: return "🚣"
        case .dance: return "💃"
        case .zumba: return "🕺"
        case .weightlifting: return "🏋️"
        case .calisthenics: return "🤸"
        case .aerobics: return "🏃"
        case .gymnastics: return "🤸‍♀️"
        case .taiChi: return "🧘‍♂️"
        case .meditation: return "🧘‍♀️"
        case .spinClass: return "🚴‍♀️"
        case .barre: return "🩰"
        case .skiing: return "⛷️"
        case .snowboarding: return "🏂"
        case .surfing: return "🏄"
        case .paddleboarding: return "🏄‍♀️"
        case .kayaking: return "🛶"
        case .sailing: return "⛵"
        case .horsebackRiding: return "🏇"
        case .archery: return "🏹"
        case .skating: return "⛸️"
        case .fencing: return "🤺"
        case .circuitTraining: return "🏋️‍♀️"
        case .triathlon: return "🏊‍♀️"
        case .diving: return "🤿"
        case .obstacleCourses: return "🔗"
        case .bootcamp: return "🏕️"
        case .frisbee: return "🥏"
        case .golf: return "⛳"
        case .tennis: return "🎾"
        case .badminton: return "🏸"
        case .cricket: return "🏏"
        case .rugby: return "🏉"
        case .basketball: return "🏀"
        case .padel: return "🎾"
        case .hyrox: return "🏃"
        }
    }
}

