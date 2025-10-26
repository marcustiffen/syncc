import CoreLocation

extension CLLocationCoordinate2D {
    func isApproximatelyEqual(to other: CLLocationCoordinate2D, threshold: Double = 0.00001) -> Bool {
        abs(latitude - other.latitude) < threshold && abs(longitude - other.longitude) < threshold
    }
}
