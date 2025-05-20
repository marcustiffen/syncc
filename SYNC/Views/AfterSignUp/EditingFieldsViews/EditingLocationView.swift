import CoreLocation
import SwiftUI

struct EditingLocationView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @Binding var location: DBLocation
    
    @Binding var isPresented: Bool
    

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                Text("Edit your home destination")
            }
            .titleModifiers()
            
            ZStack {
                MapView(location: $location)
                    .frame(maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                Image(systemName: "pin.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
            }
        }
        .frame(height: 550)
        .padding(.horizontal, 30)
        .onDisappear {
            profileModel.user?.location = location
        }
    }
}
