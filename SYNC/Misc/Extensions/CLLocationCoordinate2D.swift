import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    func isApproximatelyEqual(to other: CLLocationCoordinate2D, threshold: Double = 0.00001) -> Bool {
        abs(latitude - other.latitude) < threshold && abs(longitude - other.longitude) < threshold
    }
    
    
    func distance(to other: CLLocationCoordinate2D) -> Double {
        let thisLocation = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let otherLocation = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return thisLocation.distance(from: otherLocation) / 1000.0 // Distance in kilometers
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
