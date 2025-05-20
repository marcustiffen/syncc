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
    
    init(id: UUID? = UUID(), name: String = "Unknown", location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: -33.87271, longitude: 151.20569)) {
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
}
