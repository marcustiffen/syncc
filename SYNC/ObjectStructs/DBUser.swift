import Foundation


struct User: Codable, Equatable, Hashable {
    let uid: String
    let phoneNumber: String
    let email: String
    let name: String
    
    let gender: String
    let location: [DBLocation]
    let bio: String
    
    let fitnessTypes: [FitnessType]
    let fitnessGoals: [FitnessGoal]
    let fitnessLevel: String
    
    let height: Double
    let weight: Double
    
    let imageUrls: [String]
}
