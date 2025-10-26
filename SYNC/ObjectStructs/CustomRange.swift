import SwiftUI


struct CustomRange: Codable {
    var min: Int
    var max: Int
    
    func toDictionary() -> [String: Int] {
        return ["min": self.min, "max": self.max]
    }
}
