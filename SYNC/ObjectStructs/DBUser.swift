import Firebase
import FirebaseAuth
import Foundation
import FirebaseFirestore
import CoreLocation
import MapKit
import UIKit



struct DBUser: Codable, Equatable {
    var onboardingStep: OnboardingStep?
    
    var fcmToken: String?
    
    // Key info
    let uid: String
    var phoneNumber: String?
    var email: String?
    var name: String?
    
    // Personal Info
    var dateOfBirth: Date?
    var age: Int? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year
    }
    var sex: String?
    var location: DBLocation?
    var bio: String?
    
    // Fitness Profile
    var fitnessTypes: [String]?
    var fitnessGoals: [String]?
    var fitnessLevel: String?
    var height: Int?
    var weight: Double?
    
    // Image Urls
    var images: [DBImage]?
    
    // MatchMaking prefences (filters)
    var filteredAgeRange: CustomRange?
    var filteredSex: String?
    var filteredMatchRadius: Double?
    var filteredFitnessTypes: [String]?
    var filteredFitnessGoals: [String]?
    var filteredFitnessLevel: String?
    var blockedSex: String?
    
    // extra admin stuff
    var isBanned: Bool?
    var dailyLikes: Int?
    var lastLikeReset: Date?
    
    
    init(
        auth: AuthDataResultModel,
        dateOfBirth: Date?,
        sex: String?,
        location: DBLocation?,
        bio: String?,
        fitnessTypes: [String]?,
        fitnessGoals: [String]?,
        fitnessLevel: String?,
        height: Int?,
        weight: Double?,
        images: [DBImage]?,
        filteredAgeRange: CustomRange?,
        filteredSex: String?,
        filteredMatchRadius: Double?,
        filteredFitnessTypes: [String]?,
        filteredFitnessGoals: [String]?,
        filteredFitnessLevel: String?,
        blockedSex: String?,
        isBanned: Bool?,
        dailyLikes: Int?,
        lastLikeReset: Date?
    ) {
        self.fcmToken = nil
        self.uid = auth.uid
        self.phoneNumber = auth.phoneNumber
        self.email = auth.email
        self.name = auth.name
        self.dateOfBirth = dateOfBirth
        self.sex = sex
        self.location = location
        self.bio = bio
        self.fitnessTypes = fitnessTypes
        self.fitnessGoals = fitnessGoals
        self.fitnessLevel = fitnessLevel
        self.height = height
        self.weight = weight
        self.images = images
        self.filteredAgeRange = filteredAgeRange
        self.filteredSex = filteredSex
        self.filteredMatchRadius = filteredMatchRadius
        self.filteredFitnessTypes = filteredFitnessTypes
        self.filteredFitnessGoals = filteredFitnessGoals
        self.filteredFitnessLevel = filteredFitnessLevel
        self.blockedSex = blockedSex
        self.isBanned = isBanned
        self.dailyLikes = dailyLikes
        self.lastLikeReset = lastLikeReset
    }
    
    init(
        onboardingStep: OnboardingStep,
        deviceToken: String? = nil,
        uid: String,
        phoneNumber: String? = nil,
        email: String? = nil,
        name: String? = nil,
        dateOfBirth: Date? = nil,
        sex: String? = nil,
        location: DBLocation? = nil,
        bio: String? = nil,
        fitnessTypes: [String]? = nil,
        fitnessGoals: [String]? = nil,
        fitnessLevel: String? = nil,
        height: Int? = nil,
        weight: Double? = nil,
        images: [DBImage]? = nil,
        filteredAgeRange: CustomRange? = nil,
        filteredSex: String? = nil,
        filteredMatchRadius: Double? = nil,
        filteredFitnessTypes: [String]? = nil,
        filteredFitnessGoals: [String]? = nil,
        filteredFitnessLevel: String? = nil,
        blockedSex: String? = nil,
        isBanned: Bool? = nil,
        dailyLikes: Int? = nil,
        lastLikeReset: Date? = nil
        
    ) {
        self.onboardingStep = onboardingStep
        self.fcmToken = deviceToken
        self.uid = uid
        self.phoneNumber = phoneNumber
        self.email = email
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.sex = sex
        self.location = location
        self.bio = bio
        self.fitnessTypes = fitnessTypes
        self.fitnessGoals = fitnessGoals
        self.fitnessLevel = fitnessLevel
        self.height = height
        self.weight = weight
        self.images = images
        self.filteredAgeRange = filteredAgeRange
        self.filteredSex = filteredSex
        self.filteredMatchRadius = filteredMatchRadius
        self.filteredFitnessTypes = filteredFitnessTypes
        self.filteredFitnessGoals = filteredFitnessGoals
        self.filteredFitnessLevel = filteredFitnessLevel
        self.blockedSex = blockedSex
        self.isBanned = isBanned
        self.dailyLikes = dailyLikes
        self.lastLikeReset = lastLikeReset
    }
    
    enum CodingKeys: String, CodingKey {
        case deviceToken = "fcmToken"
        case onboardingStep, uid, phoneNumber, email, name, dateOfBirth, sex, location, bio, fitnessTypes, fitnessGoals, fitnessLevel, height, weight, images, filteredAgeRange, filteredSex, filteredMatchRadius, filteredFitnessTypes, filteredFitnessGoals, filteredFitnessLevel, blockedSex, isBanned, dailyLikes, lastLikeReset
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.onboardingStep = try container.decode(OnboardingStep.self, forKey: .onboardingStep)
        self.onboardingStep = try container.decodeIfPresent(OnboardingStep.self, forKey: .onboardingStep)
        self.fcmToken = try container.decodeIfPresent(String.self, forKey: .deviceToken)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        self.sex = try container.decodeIfPresent(String.self, forKey: .sex)
        self.location = try container.decodeIfPresent(DBLocation.self, forKey: .location)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.fitnessTypes = try container.decodeIfPresent([String].self, forKey: .fitnessTypes)
        self.fitnessGoals = try container.decodeIfPresent([String].self, forKey: .fitnessGoals)
        self.fitnessLevel = try container.decodeIfPresent(String.self, forKey: .fitnessLevel)
        self.height = try container.decodeIfPresent(Int.self, forKey: .height)
        self.weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        self.images = try container.decodeIfPresent([DBImage].self, forKey: .images)
        self.filteredAgeRange = try container.decodeIfPresent(CustomRange.self, forKey: .filteredAgeRange)
        self.filteredSex = try container.decodeIfPresent(String.self, forKey: .filteredSex)
        self.filteredMatchRadius = try container.decodeIfPresent(Double.self, forKey: .filteredMatchRadius)
        self.filteredFitnessTypes = try container.decodeIfPresent([String].self, forKey: .filteredFitnessTypes)
        self.filteredFitnessGoals = try container.decodeIfPresent([String].self, forKey: .filteredFitnessGoals)
        self.filteredFitnessLevel = try container.decodeIfPresent(String.self, forKey: .filteredFitnessLevel)
        self.blockedSex = try container.decodeIfPresent(String.self, forKey: .blockedSex)
        self.isBanned = try container.decodeIfPresent(Bool.self, forKey: .isBanned)
        self.dailyLikes = try container.decodeIfPresent(Int.self, forKey: .dailyLikes)
        self.lastLikeReset = try container.decodeIfPresent(Date.self, forKey: .lastLikeReset)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.onboardingStep, forKey: .onboardingStep)
        try container.encodeIfPresent(self.fcmToken, forKey: .deviceToken)
        try container.encode(self.uid, forKey: .uid)
        try container.encodeIfPresent(self.phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.dateOfBirth, forKey: .dateOfBirth)
        try container.encodeIfPresent(self.sex, forKey: .sex)
        try container.encodeIfPresent(self.location, forKey: .location)
        try container.encodeIfPresent(self.bio, forKey: .bio)
        try container.encodeIfPresent(self.fitnessTypes, forKey: .fitnessTypes)
        try container.encodeIfPresent(self.fitnessGoals, forKey: .fitnessGoals)
        try container.encodeIfPresent(self.fitnessLevel, forKey: .fitnessLevel)
        try container.encodeIfPresent(self.height, forKey: .height)
        try container.encodeIfPresent(self.weight, forKey: .weight)
        try container.encodeIfPresent(self.images, forKey: .images)
        try container.encodeIfPresent(self.filteredAgeRange, forKey: .filteredAgeRange)
        try container.encodeIfPresent(self.filteredSex, forKey: .filteredSex)
        try container.encodeIfPresent(self.filteredMatchRadius, forKey: .filteredMatchRadius)
        try container.encodeIfPresent(self.filteredFitnessTypes, forKey: .filteredFitnessTypes)
        try container.encodeIfPresent(self.filteredFitnessGoals, forKey: .filteredFitnessGoals)
        try container.encodeIfPresent(self.filteredFitnessLevel, forKey: .filteredFitnessLevel)
        try container.encodeIfPresent(self.blockedSex, forKey: .blockedSex)
        try container.encodeIfPresent(self.isBanned, forKey: .isBanned)
        try container.encodeIfPresent(self.dailyLikes, forKey: .dailyLikes)
        try container.encodeIfPresent(self.lastLikeReset, forKey: .lastLikeReset)
    }
    
    
    static func == (lhs: DBUser, rhs: DBUser) -> Bool {
        return lhs.uid == rhs.uid
    }
}


// Create: OnboardingSteps.swift
enum OnboardingStep: String, CaseIterable, Codable {
    case phone = "phone"
    case email = "email"
    case welcomeConnector = "welcomeConnector"
    case name = "name"
    case age = "age"
    case sex = "sex"
    case location = "location"
    case bio = "bio"
    case images = "images"
    case fitnessProfileConnector = "fitnessProfileConnector"
    case fitnessLevel = "fitnessLevel"
    case fitnessTypes = "fitnessTypes"
    case fitnessGoals = "fitnessGoals"
    case height = "height"
    case weight = "weight"
    case filterConnectorView = "filterConnectorView"
    case filteredAgeRange = "filteredAgeRange"
    case filteredSex = "filteredSex"
    case matchRadius = "matchRadius"
    case filteredFitnessTypes = "filteredFitnessTypes"
    case filteredFitnessGoals = "filteredFitnessGoals"
    case filteredFitnessLevel = "filteredFitnessLevel"
    case blockedSex = "blockedSex"
    case complete = "complete"
}
