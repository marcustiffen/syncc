//import Foundation
//
//
//
//enum StandardFitnessGoal: String, CaseIterable, Identifiable {
//    case loseWeight = "Lose Weight"
//    case buildMuscle = "Build Muscle Mass"
//    case improveEndurance = "Improve Endurance"
//    case increaseFlexibility = "Increase Flexibility"
//    case enhanceWellness = "Enhance Wellness"
//    case toneBody = "Tone Body"
//    case boostStrength = "Boost Strength"
//    case maintainFitness = "Maintain Fitness"
//    case rehabInjury = "Rehab from Injury"
//    case sportPerformance = "Improve Sport Performance"
//    case stressRelief = "Relieve Stress"
//    case dailyActivity = "Improve Daily Activity"
//    case prepareEvent = "Prepare for an Event"
//    case improveBalance = "Improve Balance"
//    case increaseEnergy = "Increase Energy"
//    case weightMaintenance = "Maintain Weight"
//    case postPregnancy = "Post-Pregnancy Fitness"
//    case prenatalFitness = "Prenatal Fitness"
//    case heartHealth = "Improve Heart Health"
//    case jointHealth = "Improve Joint Health"
//    case boostImmunity = "Boost Immunity"
//    case reduceBackPain = "Reduce Back Pain"
//    case reduceBloodPressure = "Reduce Blood Pressure"
//    case improveCoordination = "Improve Coordination"
//    case betterSleep = "Better Sleep"
//    case improveFocus = "Improve Focus"
//    case diabetesManagement = "Manage Diabetes"
//    case reduceCholesterol = "Reduce Cholesterol"
//    case detoxifyBody = "Detoxify Body"
//    case improveRunning = "Improve Running"
//    case improveCycling = "Improve Cycling"
//    case improveSwimming = "Improve Swimming"
//    case yogaMastery = "Achieve Yoga Mastery"
//    case functionalFitness = "Functional Fitness"
//    case adventureReadiness = "Prepare for Adventures"
//    case spiritualHealth = "Enhance Spiritual Health"
//    case martialArts = "Martial Arts Training"
//    case selfDefense = "Self-Defense Readiness"
//    case postureImprovement = "Improve Posture"
//    
//    
//
//    var id: String { self.rawValue }
//}
//
//
//struct FitnessGoalHelper {
//    static let emojiForId: [String: String] = [
//        "Lose Weight": "⚖️",
//        "Build Muscle Mass": "💪",
//        "Improve Endurance": "🏃‍♂️",
//        "Increase Flexibility": "🤸‍♀️",
//        "Enhance Wellness": "🌱",
//        "Tone Body": "🏋️‍♀️",
//        "Boost Strength": "🦾",
//        "Maintain Fitness": "✅",
//        "Rehab from Injury": "🩹",
//        "Improve Sport Performance": "🏅",
//        "Relieve Stress": "🧘‍♀️",
//        "Improve Daily Activity": "🚶‍♂️",
//        "Prepare for an Event": "🎯",
//        "Improve Balance": "🤹‍♀️",
//        "Increase Energy": "⚡️",
//        "Maintain Weight": "⚖️",
//        "Post-Pregnancy Fitness": "👶",
//        "Prenatal Fitness": "🤰",
//        "Improve Heart Health": "❤️",
//        "Improve Joint Health": "🦵",
//        "Boost Immunity": "🛡️",
//        "Reduce Back Pain": "🪑",
//        "Reduce Blood Pressure": "🩸",
//        "Improve Coordination": "🔄",
//        "Better Sleep": "💤",
//        "Improve Focus": "🎯",
//        "Manage Diabetes": "🍎",
//        "Reduce Cholesterol": "🍳",
//        "Detoxify Body": "🧴",
//        "Improve Running": "🏃",
//        "Improve Cycling": "🚴",
//        "Improve Swimming": "🏊",
//        "Achieve Yoga Mastery": "🧘",
//        "Functional Fitness": "🛠️",
//        "Prepare for Adventures": "🏔️",
//        "Enhance Spiritual Health": "🕊️",
//        "Martial Arts Training": "🥋",
//        "Self-Defense Readiness": "🛡️",
//        "Improve Posture": "🪑"
//    ]
//    
//    static func emoji(for id: String) -> String {
//        emojiForId[id] ?? "❓"
//    }
//}
//
//



import Foundation

enum StandardFitnessGoal: String, CaseIterable, Identifiable {
    // Body Composition & Weight
    case loseFat = "Lose Fat"
    case loseWeight = "Lose Weight"
    case buildMuscle = "Build Muscle"
    case improveBodyComposition = "Improve Body Composition"
    case toneBody = "Tone the Body"
    case improveAesthetics = "Improve Aesthetics"
    
    // Strength & Performance
    case increaseStrength = "Increase Strength"
    case increasePower = "Increase Power"
    case improveEndurance = "Improve Endurance"
    case improveCardiovascularFitness = "Improve Cardiovascular Fitness"
    case improveMuscularEndurance = "Improve Muscular Endurance"
    case improveSpeed = "Improve Speed"
    case improveAgility = "Improve Agility"
    case improveCoordination = "Improve Coordination"
    case improveBalance = "Improve Balance"
    case improveMobility = "Improve Mobility"
    case improveFunctionalFitness = "Improve Functional Fitness"
    case improvePosture = "Improve Posture"
    case improveAthleticPerformance = "Improve Overall Athletic Performance"
    
    // Health & Wellness
    case improveOverallHealth = "Improve Overall Health"
    case improveMetabolicHealth = "Improve Metabolic Health"
    case improveHeartHealth = "Improve Heart Health"
    case lowerBloodPressure = "Lower Blood Pressure"
    case lowerRestingHeartRate = "Lower Resting Heart Rate"
    case improveCholesterol = "Improve Cholesterol"
    case improveBloodSugarControl = "Improve Blood Sugar Control"
    case improveDigestion = "Improve Digestion"
    case improveCirculation = "Improve Circulation"
    case reduceInflammation = "Reduce Inflammation"
    case increaseBoneDensity = "Increase Bone Density"
    case reduceJointPain = "Reduce Joint Pain"
    case reduceChronicPain = "Reduce Chronic Pain"
    case strengthenImmuneSystem = "Strengthen Immune System"
    case improveRespiratoryHealth = "Improve Respiratory Health"
    case improveBreathingEfficiency = "Improve Breathing Efficiency"
    case increaseLongevity = "Increase Longevity"
    case improveSleep = "Improve Sleep"
    case reduceStress = "Reduce Stress"
    case improveMentalHealth = "Improve Mental Health"
    
    // Recovery & Injury
    case rehabFromInjury = "Rehab from Injury"
    case preventInjuries = "Prevent Injuries"
    
    // Lifestyle & Habit Formation
    case buildDiscipline = "Build Discipline"
    case buildConsistency = "Build Consistency"
    case buildDailyMovementHabit = "Build a Daily Movement Habit"
    case reduceSedentaryTime = "Reduce Sedentary Time"
    case increaseNEAT = "Increase NEAT"
    case improveBodyAwareness = "Improve Body Awareness"
    case improveConfidence = "Improve Confidence"
    
    // Sport / Activity Preparation
    case prepareForRace = "Prepare for a Race"
    case prepareForTriathlon = "Prepare for a Triathlon"
    case prepareForSportSeason = "Prepare for a Sport Season"
    case prepareForFitnessCompetition = "Prepare for a Fitness Competition"
    case learnNewSport = "Learn a New Sport or Skill"
    
    // Women's Health / Population-Specific
    case prenatalFitness = "Prenatal Fitness Goals"
    case postnatalFitness = "Postnatal Fitness Goals"
    case manageMenopause = "Manage Menopause-Related Changes"
    case healthyAging = "Healthy Aging Goals"
    
    var id: String { self.rawValue }
}

struct FitnessGoalHelper {
    static let emojiForId: [String: String] = [
        // Body Composition & Weight
        "Lose Fat": "🔥",
        "Lose Weight": "⚖️",
        "Build Muscle": "💪",
        "Gain Healthy Weight": "📈",
        "Improve Body Composition": "🎯",
        "Tone/Shape the Body": "🏋️‍♀️",
        "Improve Aesthetics": "✨",
        
        // Strength & Performance
        "Increase Strength": "💪",
        "Increase Power": "⚡",
        "Improve Endurance": "🏃‍♂️",
        "Improve Cardiovascular Fitness": "❤️",
        "Improve Muscular Endurance": "🦾",
        "Improve Speed": "💨",
        "Improve Agility": "🤸",
        "Improve Coordination": "🔄",
        "Improve Balance": "⚖️",
        "Improve Mobility": "🤸‍♀️",
        "Improve Flexibility": "🤸‍♀️",
        "Improve Core Strength": "💪",
        "Improve Functional Fitness": "🛠️",
        "Improve Posture": "🪑",
        "Improve Overall Athletic Performance": "🏅",
        
        // Health & Wellness
        "Improve Overall Health": "🌱",
        "Improve Metabolic Health": "⚗️",
        "Improve Heart Health": "❤️",
        "Lower Blood Pressure": "🩸",
        "Lower Resting Heart Rate": "💓",
        "Improve Cholesterol": "🩺",
        "Improve Blood Sugar Control": "🍎",
        "Improve Digestion": "🥗",
        "Improve Circulation": "💉",
        "Reduce Inflammation": "🧊",
        "Increase Bone Density": "🦴",
        "Reduce Joint Pain": "🦵",
        "Reduce Chronic Pain": "🩹",
        "Strengthen Immune System": "🛡️",
        "Improve Respiratory Health": "🫁",
        "Improve Breathing Efficiency": "💨",
        "Increase Longevity": "⏳",
        "Improve Sleep": "💤",
        "Reduce Stress": "🧘‍♀️",
        "Improve Mental Health": "🧠",
        
        // Recovery & Injury
        "Rehab from Injury": "🩹",
        "Prevent Injuries": "🛡️",
        "Improve Recovery Rate": "♻️",
        
        // Lifestyle & Habit Formation
        "Build Discipline": "🎯",
        "Build Consistency": "📅",
        "Build a Daily Movement Habit": "🚶‍♂️",
        "Reduce Sedentary Time": "⏰",
        "Increase NEAT": "🔋",
        "Maintain Independence with Age": "👴",
        "Improve Body Awareness": "🧘",
        "Improve Confidence": "💫",
        
        // Sport / Activity Preparation
        "Prepare for a Race": "🏁",
        "Prepare for a Triathlon": "🏊‍♀️",
        "Prepare for a Sport Season": "⚽️",
        "Prepare for a Fitness Competition": "🏆",
        "Learn a New Sport or Skill": "📚",
        
        // Women's Health / Population-Specific
        "Prenatal Fitness Goals": "🤰",
        "Postnatal Fitness Goals": "👶",
        "Manage Menopause-Related Changes": "🌸",
        "Healthy Aging Goals": "🌟",
        
        // Region-Specific Goals
        "Build Stronger Legs": "🦵",
        "Build Stronger Glutes": "🍑",
        "Build Stronger Back": "💪",
        "Build Stronger Shoulders": "💪",
        "Build Stronger Arms": "💪",
        "Strengthen the Core": "💪",
        "Improve Grip Strength": "✊",
        "Strengthen Joints": "🦴"
    ]
    
    static func emoji(for id: String) -> String {
        emojiForId[id] ?? "❓"
    }
}
