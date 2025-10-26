import Foundation
import SwiftUI
import MapKit


struct ActivityMapView: View {
    let location: DBLocation
    
    var body: some View {
        ZStack {
            StaticMapView(location: location)
                .frame(maxWidth: .infinity)
                .frame(height: 150)
            
            Image(systemName: "mappin")
                .font(.system(size: 20))
                .foregroundColor(.red)
        }
        .cornerRadius(12)
    }
}

struct StaticMapView: UIViewRepresentable {
    let location: DBLocation
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        mapView.isPitchEnabled = false
        mapView.isRotateEnabled = false
        
        // Set a zoomed-in region (500 meters on each side)
        let region = MKCoordinateRegion(
            center: location.location,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: false)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Update region if location changes
        let region = MKCoordinateRegion(
            center: location.location,
            latitudinalMeters: 500,
            longitudinalMeters: 500
        )
        mapView.setRegion(region, animated: false)
    }
}
