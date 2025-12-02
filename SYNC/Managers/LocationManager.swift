import CoreLocation
import SwiftUI



class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var isRequestingLocation = false
    
    override init() {
        self.authorizationStatus = CLLocationManager().authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        isRequestingLocation = true
        
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location services are disabled")
            isRequestingLocation = false
            return
        }
        
        // Check current authorization status
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            // Request authorization - will trigger didChangeAuthorization
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // Already authorized, request location
            locationManager.requestLocation()
        case .denied, .restricted:
            print("Location access denied or restricted")
            isRequestingLocation = false
        @unknown default:
            isRequestingLocation = false
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.coordinate = location.coordinate
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
        
        // When authorization changes to authorized, automatically request location
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        }
    }
}
