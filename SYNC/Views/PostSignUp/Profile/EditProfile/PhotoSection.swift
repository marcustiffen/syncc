import SwiftUI


struct PhotoSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Photos")
                .h2Style()
            
            PhotoManagementView()
        }
        .foregroundStyle(.syncBlack)
        .padding(.vertical, 10)
    }
}
