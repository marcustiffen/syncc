import SwiftUI


struct PhotoSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Edit Your Photos")
                .h2Style()
            
            PhotoManagementView()
        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 10)
    }
}
