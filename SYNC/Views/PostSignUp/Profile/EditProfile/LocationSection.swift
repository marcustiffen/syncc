import SwiftUI
import CoreLocation


struct LocationSection: View {
    @ObservedObject var profileModel: ProfileModel
    @State private var showLocationEditView = false
    
    var body: some View {
        HStack {
            Button(action: { showLocationEditView = true }) {
                Text("Location")
                    
                Spacer()
                Image(systemName: "chevron.down")
            }
            .h2Style()
            .foregroundStyle(.syncBlack)
        }
        .padding(.vertical, 20)
        .background(SectionDivider())
        .sheet(isPresented: $showLocationEditView) {
            EditingLocationView(
                location: Binding(
                    get: { profileModel.user?.location ?? DBLocation(id: UUID(), name: "", location: CLLocationCoordinate2D(latitude: 0, longitude: 50)) },
                    set: { profileModel.user?.location = $0 }
                ),
                isPresented: $showLocationEditView
            )
        }
    }
}
