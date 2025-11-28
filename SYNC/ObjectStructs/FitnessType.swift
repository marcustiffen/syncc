//import Foundation
//
//
//enum StandardFitnessType: String, CaseIterable, Identifiable {
//    case gym = "Gym"
//    case running = "Running"
//    case cycling = "Cycling"
//    case swimming = "Swimming"
//    case yoga = "Yoga"
//    case pilates = "Pilates"
//    case crossfit = "CrossFit"
//    case hiking = "Hiking"
//    case walking = "Walking"
//    case boxing = "Boxing"
//    case martialArts = "Martial Arts"
//    case homeWorkouts = "Home Workouts"
//    case outdoorWorkouts = "Outdoor Workouts"
//    case parkour = "Parkour"
//    case rockClimbing = "Rock Climbing"
//    case rowing = "Rowing"
//    case dance = "Dance"
//    case zumba = "Zumba"
//    case weightlifting = "Weightlifting"
//    case calisthenics = "Calisthenics"
//    case aerobics = "Aerobics"
//    case gymnastics = "Gymnastics"
//    case taiChi = "Tai Chi"
//    case meditation = "Meditation"
//    case spinClass = "Spin Class"
//    case barre = "Barre"
//    case skiing = "Skiing"
//    case snowboarding = "Snowboarding"
//    case surfing = "Surfing"
//    case paddleboarding = "Paddleboarding"
//    case kayaking = "Kayaking"
//    case sailing = "Sailing"
//    case horsebackRiding = "Horseback Riding"
//    case archery = "Archery"
//    case skating = "Skating"
//    case fencing = "Fencing"
//    case circuitTraining = "Circuit Training"
//    case triathlon = "Triathlon"
//    case diving = "Diving"
//    case obstacleCourses = "Obstacle Courses"
//    case bootcamp = "Bootcamp"
//    case frisbee = "Frisbee"
//    case golf = "Golf"
//    case tennis = "Tennis"
//    case badminton = "Badminton"
//    case cricket = "Cricket"
//    case rugby = "Rugby"
//    case basketball = "Basketball"
//    case padel = "Padel"
//    case hyrox = "Hyrox"
//
//    var id: String { self.rawValue }
//}
//
//
//
//struct FitnessTypeHelper {
//    static let emojiForId: [String: String] = [
//        "Gym": "🏋️‍♂️",
//        "Running": "🏃",
//        "Cycling": "🚴",
//        "Swimming": "🏊",
//        "Yoga": "🧘",
//        "Pilates": "🩰",
//        "CrossFit": "🔥",
//        "Hiking": "🥾",
//        "Walking": "🚶",
//        "Boxing": "🥊",
//        "Martial Arts": "🥋",
//        "Home Workouts": "🏠",
//        "Outdoor Workouts": "🌳",
//        "Parkour": "🤸‍♂️",
//        "Rock Climbing": "🧗",
//        "Rowing": "🚣",
//        "Dance": "💃",
//        "Zumba": "🕺",
//        "Weightlifting": "🏋️",
//        "Calisthenics": "🤸",
//        "Aerobics": "🏃",
//        "Gymnastics": "🤸‍♀️",
//        "Tai Chi": "🧘‍♂️",
//        "Meditation": "🧘‍♀️",
//        "Spin Class": "🚴‍♀️",
//        "Barre": "🩰",
//        "Skiing": "⛷️",
//        "Snowboarding": "🏂",
//        "Surfing": "🏄",
//        "Paddleboarding": "🏄‍♀️",
//        "Kayaking": "🛶",
//        "Sailing": "⛵",
//        "Horseback Riding": "🏇",
//        "Archery": "🏹",
//        "Skating": "⛸️",
//        "Fencing": "🤺",
//        "Circuit Training": "🏋️‍♀️",
//        "Triathlon": "🏊‍♀️",
//        "Diving": "🤿",
//        "Obstacle Courses": "🔗",
//        "Bootcamp": "🏕️",
//        "Frisbee": "🥏",
//        "Golf": "⛳",
//        "Tennis": "🎾",
//        "Badminton": "🏸",
//        "Cricket": "🏏",
//        "Rugby": "🏉",
//        "Basketball": "🏀",
//        "Padel": "🎾",
//        "Hyrox": "🏃"
//    ]
//    
//    static func emoji(for id: String) -> String {
//        emojiForId[id] ?? "❓"
//    }
//}
//
//
//


import Foundation

enum StandardFitnessType: String, CaseIterable, Identifiable {
    // Team / Ball Sports
    case rugby = "Rugby"
    case soccer = "Football"
    case americanFootball = "American Football"
    case basketball = "Basketball"
    case baseball = "Baseball"
    case softball = "Softball"
    case volleyball = "Volleyball"
    case iceHockey = "Ice Hockey"
    case fieldHockey = "Field Hockey"
    case handball = "Handball"
    case lacrosse = "Lacrosse"
    case cricket = "Cricket"
    case netball = "Netball"
    case gaelicFootball = "Gaelic Football"
    case australianRulesFootball = "Australian Rules Football"
    case waterPolo = "Water Polo"
    case ultimateFrisbee = "Ultimate Frisbee"
    
    // Racket / Paddle Sports
    case tennis = "Tennis"
    case padel = "Padel"
    case pickleball = "Pickleball"
    case badminton = "Badminton"
    case squash = "Squash"
    case tableTennis = "Table Tennis"
    
    // Endurance Sports
    case running = "Running"
    case distanceRunning = "Distance Running"
    case sprinting = "Sprinting"
    case trailRunning = "Trail Running"
    case triathlon = "Triathlon"
    case roadCycling = "Road Cycling"
    case mountainBiking = "Mountain Biking"
    case indoorCycling = "Indoor Cycling"
    case trackAndField = "Track & Field"
    case raceWalking = "Race Walking"
    
    // Water Sports
    case swimming = "Swimming"
    case kayaking = "Kayaking"
    case canoeing = "Canoeing"
    case rowing = "Rowing"
    case standUpPaddleboarding = "Stand-Up Paddleboarding"
    case surfing = "Surfing"
    case deepWaterRunning = "Deep Water Running"
    case aquaAerobics = "Aqua Aerobics"
    case sailing = "Sailing"
    case windsurfing = "Windsurfing"
    case kiteboarding = "Kiteboarding"
    
    // Winter Sports
    case downhillSkiing = "Skiing"
    case crossCountrySkiing = "Cross-Country Skiing"
    case snowboarding = "Snowboarding"
    
    // Combat Sports & Martial Arts
    case boxing = "Boxing"
    case kickboxing = "Kickboxing"
    case muayThai = "Muay Thai"
    case brazilianJiuJitsu = "Brazilian Jiu-Jitsu"
    case judo = "Judo"
    case karate = "Karate"
    case taekwondo = "Taekwondo"
    case kravMaga = "Krav Maga"
    case wrestling = "Wrestling"
    case mma = "Mixed Martial Arts"
    
    // Strength / Conditioning Disciplines
    case powerlifting = "Powerlifting"
    case olympicWeightlifting = "Olympic Weightlifting"
    case bodybuilding = "Bodybuilding"
    case strongman = "Strongman"
    case functionalFitness = "Functional Fitness"
    case crossfit = "CrossFit"
    case calisthenics = "Calisthenics"
    case gymnastics = "Gymnastics"
    case circuit = "Circuit Training"
    case bootcamp = "Bootcamp"
    
    // Branded / Competition Fitness
    case hyrox = "Hyrox"
    
    // Mind–Body / Low-Impact
    case yoga = "Yoga"
    case pilates = "Pilates"
    case barre = "Barre"
    case taiChi = "Tai Chi"
    case qigong = "Qigong"
    case danceFitness = "Dance Fitness"
    case zumba = "Zumba"
    case aerobics = "Aerobics"
    
    // Outdoor / Adventure / Lifestyle
    case hiking = "Hiking"
    case mountaineering = "Mountaineering"
    case orienteering = "Orienteering"
    case climbing = "Climbing"
    case parkour = "Parkour"
    case rollerblading = "Rollerblading"
    case skateboarding = "Skateboarding"
    case walking = "Walking"
    
    var id: String { self.rawValue }
}

struct FitnessTypeHelper {
    static let emojiForId: [String: String] = [
        // Team / Ball Sports
        "Rugby": "🏉",
        "Football": "⚽️",
        "American Football": "🏈",
        "Basketball": "🏀",
        "Baseball": "⚾️",
        "Softball": "🥎",
        "Volleyball": "🏐",
        "Ice Hockey": "🏒",
        "Field Hockey": "🏑",
        "Handball": "🤾",
        "Lacrosse": "🥍",
        "Cricket": "🏏",
        "Netball": "🏐",
        "Gaelic Football": "⚽️",
        "Australian Rules Football": "🏈",
        "Water Polo": "🤽",
        "Ultimate Frisbee": "🥏",
        
        // Racket / Paddle Sports
        "Tennis": "🎾",
        "Padel": "🎾",
        "Pickleball": "🏓",
        "Badminton": "🏸",
        "Squash": "🎾",
        "Table Tennis": "🏓",
        
        // Endurance Sports
        "Running": "🏃",
        "Distance Running": "🏃‍♂️",
        "Sprinting": "💨",
        "Trail Running": "🥾",
        "Triathlon": "🏊‍♀️",
        "Road Cycling": "🚴",
        "Mountain Biking": "🚵",
        "Indoor Cycling": "🚴‍♀️",
        "Track & Field": "🏃",
        "Race Walking": "🚶‍♂️",
        
        // Water Sports
        "Swimming": "🏊",
        "Kayaking": "🛶",
        "Canoeing": "🛶",
        "Rowing": "🚣",
        "Stand-Up Paddleboarding": "🏄‍♀️",
        "Surfing": "🏄",
        "Deep Water Running": "🏊",
        "Aqua Aerobics": "💦",
        "Sailing": "⛵",
        "Windsurfing": "🏄",
        "Kiteboarding": "🪁",
        
        // Winter Sports
        "Downhill Skiing": "⛷️",
        "Cross-Country Skiing": "🎿",
        "Snowboarding": "🏂",
        
        // Combat Sports & Martial Arts
        "Boxing": "🥊",
        "Kickboxing": "🥊",
        "Muay Thai": "🥋",
        "Brazilian Jiu-Jitsu": "🥋",
        "Judo": "🥋",
        "Karate": "🥋",
        "Taekwondo": "🥋",
        "Krav Maga": "🥋",
        "Wrestling": "🤼",
        "Mixed Martial Arts": "🥊",
        "Martial Arts": "🥋",
        
        // Strength / Conditioning Disciplines
        "Powerlifting": "🏋️",
        "Olympic Weightlifting": "🏋️‍♂️",
        "Bodybuilding": "💪",
        "Strongman": "🦾",
        "Functional Fitness": "🛠️",
        "CrossFit": "🔥",
        "Calisthenics": "🤸",
        "Gymnastics": "🤸‍♀️",
        "Kettlebell": "🏋️",
        "TRX": "🔗",
        "Resistance Band": "🎗️",
        "Sandbag": "💼",
        "Sled Pushing": "🛷",
        "Plyometrics": "💥",
        "Battle Rope": "🪢",
        "Circuit Training": "🔄",
        "Bootcamp": "🏕️",
        "HIIT": "⚡",
        "LISS": "🚶",
        "Core Training": "💪",
        "Stability Training": "⚖️",
        "Mobility": "🤸",
        "Flexibility": "🤸‍♀️",
        
        // Branded / Competition Fitness
        "Hyrox": "🏃",
        "Spartan Race": "🛡️",
        "Tough Mudder": "🥾",
        "Warrior Dash": "⚔️",
        "Functional Fitness Competitions": "🏆",
        
        // Mind–Body / Low-Impact
        "Yoga": "🧘",
        "Hot Yoga": "🧘‍♀️",
        "Pilates": "🩰",
        "Barre": "🩰",
        "Tai Chi": "🧘‍♂️",
        "Qigong": "☯️",
        "Dance Fitness": "💃",
        "Zumba": "🕺",
        "Aerobics": "🏃",
        
        // Outdoor / Adventure / Lifestyle
        "Hiking": "🥾",
        "Mountaineering": "🏔️",
        "Orienteering": "🧭",
        "Climbing": "🧗",
        "Parkour": "🤸‍♂️",
        "Rollerblading": "🛼",
        "Skateboarding": "🛹",
        "Nordic Walking": "🚶",
        "Gardening": "🌱",
        "Walking": "🚶",
        
        // Machine-Based
        "Rowing Machine": "🚣",
        "Elliptical": "🏃",
        "Stair Climber": "🪜",
        "Treadmill": "🏃",
        "Air Bike": "🚴",
        "SkiErg": "⛷️"
    ]
    
    static func emoji(for id: String) -> String {
        emojiForId[id] ?? "❓"
    }
}
