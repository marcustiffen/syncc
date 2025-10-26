import Foundation



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
}


struct FitnessGoalHelper {
    static let emojiForId: [String: String] = [
        "Lose Weight": "⚖️",
        "Build Muscle Mass": "💪",
        "Improve Endurance": "🏃‍♂️",
        "Increase Flexibility": "🤸‍♀️",
        "Enhance Wellness": "🌱",
        "Tone Body": "🏋️‍♀️",
        "Boost Strength": "🦾",
        "Maintain Fitness": "✅",
        "Rehab from Injury": "🩹",
        "Improve Sport Performance": "🏅",
        "Relieve Stress": "🧘‍♀️",
        "Improve Daily Activity": "🚶‍♂️",
        "Prepare for an Event": "🎯",
        "Improve Balance": "🤹‍♀️",
        "Increase Energy": "⚡️",
        "Maintain Weight": "⚖️",
        "Post-Pregnancy Fitness": "👶",
        "Prenatal Fitness": "🤰",
        "Improve Heart Health": "❤️",
        "Improve Joint Health": "🦵",
        "Boost Immunity": "🛡️",
        "Reduce Back Pain": "🪑",
        "Reduce Blood Pressure": "🩸",
        "Improve Coordination": "🔄",
        "Better Sleep": "💤",
        "Improve Focus": "🎯",
        "Manage Diabetes": "🍎",
        "Reduce Cholesterol": "🍳",
        "Detoxify Body": "🧴",
        "Improve Running": "🏃",
        "Improve Cycling": "🚴",
        "Improve Swimming": "🏊",
        "Achieve Yoga Mastery": "🧘",
        "Functional Fitness": "🛠️",
        "Prepare for Adventures": "🏔️",
        "Enhance Spiritual Health": "🕊️",
        "Martial Arts Training": "🥋",
        "Self-Defense Readiness": "🛡️",
        "Improve Posture": "🪑"
    ]
    
    static func emoji(for id: String) -> String {
        emojiForId[id] ?? "❓"
    }
}


