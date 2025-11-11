import CoreLocation
import MapKit
import Firebase
import Foundation

struct DBLocation: Identifiable, Codable {
    var id: UUID?
    var name: String
    var location: CLLocationCoordinate2D
    
    enum CodingKeys: String, CodingKey {
        case id, name, location
    }
    
    init(id: UUID? = UUID(), name: String = "Sydney", location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -33.87271, longitude: 151.20569)) {
        self.id = id
        self.name = name
        self.location = location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        if let geoPoint = try container.decodeIfPresent(GeoPoint.self, forKey: .location) {
            self.location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        } else {
            self.location = CLLocationCoordinate2D(latitude: 51.50335, longitude: 0.07940)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        
        try container.encode(GeoPoint(latitude: location.latitude, longitude: location.longitude), forKey: .location)
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            "id": id?.uuidString ?? "",
            "name": name,
            "location": GeoPoint(latitude: location.latitude, longitude: location.longitude)
        ]
    }
}



extension DBLocation {
    /// Calculates the distance between this location and another DBLocation
    /// - Parameter other: The other DBLocation to calculate distance to
    /// - Returns: Distance in kilometers
    func distance(to other: DBLocation) -> Double {
        let thisLocation = CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)
        let otherLocation = CLLocation(latitude: other.location.latitude, longitude: other.location.longitude)
        return thisLocation.distance(from: otherLocation) / 1000.0 // Distance in kilometers
    }
}
