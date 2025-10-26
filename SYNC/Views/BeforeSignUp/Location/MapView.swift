import CoreLocation
import SwiftUI
import MapKit


struct MapView: UIViewRepresentable {
    @Binding var location: DBLocation
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isUserInteractionEnabled = true
        mapView.showsUserLocation = true
        
        // Set the initial region to center on the provided location
        let initialRegion = MKCoordinateRegion(center: location.location, latitudinalMeters: 10000, longitudinalMeters: 10000)
        mapView.setRegion(initialRegion, animated: true)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Only update region if the location changes externally
        let region = MKCoordinateRegion(center: location.location, latitudinalMeters: 10000, longitudinalMeters: 10000)
        if !mapView.centerCoordinate.isApproximatelyEqual(to: location.location) {
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        let geocoder = CLGeocoder()
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let newCenter = mapView.centerCoordinate
            
            // Update the coordinate in DBLocation
            DispatchQueue.main.async {
                self.parent.location.location = newCenter
            }
            
            // Reverse geocode the new location to get the place name
            geocoder.reverseGeocodeLocation(CLLocation(latitude: newCenter.latitude, longitude: newCenter.longitude)) { placemarks, error in
                guard let placemark = placemarks?.first, error == nil else {
                    print("Geocoding error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                let placeName = placemark.subLocality ?? placemark.locality ?? placemark.administrativeArea ?? placemark.country ?? "Unknown Location"
                
                // Update the name in DBLocation
                DispatchQueue.main.async {
                    self.parent.location.name = placeName
                }
            }
        }
    }
}
