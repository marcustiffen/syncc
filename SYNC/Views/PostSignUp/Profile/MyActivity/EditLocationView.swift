import SwiftUI


struct EditLocationView: View {
    @Binding var location: DBLocation
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileModel: ProfileModel
    
    var body: some View {
        VStack {
            titleView()
            
            Spacer()
            
            ZStack {
                MapView(location: $location)
                    .frame(maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                
                Image(systemName: "pin.fill")
                    .font(.callout)
                    .foregroundStyle(.red)
            }
            .frame(maxHeight: .infinity)
            .padding(.vertical, 50)
        }
        .padding(.horizontal, 10)
        .navigationBarBackButtonHidden(true)
    }
    
    private func titleView() -> some View {
        HStack {
            SyncBackButton {
                dismiss()
            }
            Text("Edit Location")
            Spacer()
        }
        .h1Style()
        .foregroundStyle(.syncBlack)
    }
}
