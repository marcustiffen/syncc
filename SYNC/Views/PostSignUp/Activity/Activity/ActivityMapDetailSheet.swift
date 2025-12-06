import EventKit
import MapKit
import SwiftUI


struct ActivityMapDetailSheet: View {
    let activity: Activity
    let location: DBLocation
    @Binding var isPresented: Bool
    
    @State private var region: MKCoordinateRegion
    
    init(activity: Activity, location: DBLocation, isPresented: Binding<Bool>) {
        self.activity = activity
        self.location = location
        self._isPresented = isPresented
        
        // Initialize with activity location
        self._region = State(initialValue: MKCoordinateRegion(
            center: location.location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Full screen map
                Map(coordinateRegion: $region, annotationItems: [location]) { loc in
                    MapMarker(coordinate: loc.location, tint: .syncGreen)
                }
                .ignoresSafeArea()
                
                // Activity info card overlay
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(activity.name)
                                    .font(.h2)
                                    .bold()
                                    .foregroundColor(.syncBlack)
                                
                                Text(formatDate(activity.startTime))
                                    .font(.bodyText)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                openInMaps()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                        .font(.system(size: 12))
                                    Text("Directions")
                                        .font(.h2).fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.syncBlack)
                                )
                            }
                        }
                        
                        Divider()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.syncGreen)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(location.name)
                                    .font(.h2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.syncBlack)
                                
                                Text(coordinateString)
                                    .font(.bodyText)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        if let description = activity.description {
                            Divider()
                            
                            Text(description)
                                .font(.bodyText)
                                .foregroundColor(.secondary)
                                .lineLimit(3)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: -5)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.gray.opacity(0.6))
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
    
    private var coordinateString: String {
        String(format: "%.4f, %.4f", location.location.latitude, location.location.longitude)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: location.location)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = activity.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}
