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
