import Foundation


struct Message: Identifiable, Codable, Equatable {
    var id: String
    var text: String
    var senderId: String
    var timestamp: Date
    var seen: Bool
    
    
}
