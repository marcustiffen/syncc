import Foundation


struct FitnessGoal: Identifiable, Codable, Equatable {
    var id: String
    var goal: String
    var emoji: String
    
    enum CodingKeys: String, CodingKey {
        case id, goal, emoji
    }
    
    init(id: String = "Unknown", goal: String = "Unknown", emoji: String = "Unkown") {
        self.id = id
        self.goal = goal
        self.emoji = emoji
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? "Unknown"
        goal = try container.decodeIfPresent(String.self, forKey: .goal) ?? "Unknown"
        emoji = try container.decodeIfPresent(String.self, forKey: .emoji) ?? "Unknown"
    }
}

enum StandardFitnessGoal: String, CaseIterable, Identifiable {
    case loseWeight = "Lose Weight"
    case buildMuscle = "Build Muscle Mass"
    case improveEndurance = "Improve Endurance"
    case increaseFlexibility = "Increase Flexibility"
    case enhanceWellness = "Enhance Wellness"
    case toneBody = "Tone Body"
    case boostStrength = "Boost Strength"
    case maintainFitness = "Maintain Fitness"
    case rehabInjury = "Rehab from Injury"
    case sportPerformance = "Improve Sport Performance"
    case stressRelief = "Relieve Stress"
    case dailyActivity = "Improve Daily Activity"
    case prepareEvent = "Prepare for an Event"
    case improveBalance = "Improve Balance"
    case increaseEnergy = "Increase Energy"
    case weightMaintenance = "Maintain Weight"
    case postPregnancy = "Post-Pregnancy Fitness"
    case prenatalFitness = "Prenatal Fitness"
    case heartHealth = "Improve Heart Health"
    case jointHealth = "Improve Joint Health"
    case boostImmunity = "Boost Immunity"
    case reduceBackPain = "Reduce Back Pain"
    case reduceBloodPressure = "Reduce Blood Pressure"
    case improveCoordination = "Improve Coordination"
    case betterSleep = "Better Sleep"
    case improveFocus = "Improve Focus"
    case diabetesManagement = "Manage Diabetes"
    case reduceCholesterol = "Reduce Cholesterol"
    case detoxifyBody = "Detoxify Body"
    case improveRunning = "Improve Running"
    case improveCycling = "Improve Cycling"
    case improveSwimming = "Improve Swimming"
    case yogaMastery = "Achieve Yoga Mastery"
    case functionalFitness = "Functional Fitness"
    case adventureReadiness = "Prepare for Adventures"
    case spiritualHealth = "Enhance Spiritual Health"
    case martialArts = "Martial Arts Training"
    case selfDefense = "Self-Defense Readiness"
    case postureImprovement = "Improve Posture"
    
    

    var id: String { self.rawValue }
    var emoji: String {
        switch self {
        case .loseWeight: return "⚖️"
        case .buildMuscle: return "💪"
        case .improveEndurance: return "🏃‍♂️"
        case .increaseFlexibility: return "🤸‍♀️"
        case .enhanceWellness: return "🌱"
        case .toneBody: return "🏋️‍♀️"
        case .boostStrength: return "🦾"
        case .maintainFitness: return "✅"
        case .rehabInjury: return "🩹"
        case .sportPerformance: return "🏅"
        case .stressRelief: return "🧘‍♀️"
        case .dailyActivity: return "🚶‍♂️"
        case .prepareEvent: return "🎯"
        case .improveBalance: return "🤹‍♀️"
        case .increaseEnergy: return "⚡️"
        case .weightMaintenance: return "⚖️"
//        case .healthyAging: return "🕰️"
        case .postPregnancy: return "👶"
        case .prenatalFitness: return "🤰"
        case .heartHealth: return "❤️"
        case .jointHealth: return "🦵"
        case .boostImmunity: return "🛡️"
        case .reduceBackPain: return "🪑"
        case .reduceBloodPressure: return "🩸"
        case .improveCoordination: return "🔄"
        case .betterSleep: return "💤"
        case .improveFocus: return "🎯"
//        case .increaseStamina: return "🔥"
//        case .metabolicHealth: return "🌡️"
        case .diabetesManagement: return "🍎"
        case .reduceCholesterol: return "🍳"
        case .detoxifyBody: return "🧴"
//        case .weightLiftingGoals: return "🏋️‍♂️"
        case .improveRunning: return "🏃"
        case .improveCycling: return "🚴"
        case .improveSwimming: return "🏊"
        case .yogaMastery: return "🧘"
        case .functionalFitness: return "🛠️"
        case .adventureReadiness: return "🏔️"
//        case .outdoorFitness: return "🌳"
//        case .mentalClarity: return "🧠"
        case .spiritualHealth: return "🕊️"
//        case .socialWellness: return "👥"
//        case .careerWellness: return "📈"
        case .martialArts: return "🥋"
        case .selfDefense: return "🛡️"
//        case .teamSports: return "⚽️"
//        case .individualSports: return "🎾"
        case .postureImprovement: return "🪑"
        }
    }
}

