import SwiftUI



struct EditView: View {
    @EnvironmentObject var profileModel: ProfileModel
    @State private var isEditing = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 10) {
                headerSection
                    .padding(.top, 10)
                
                ScrollView(showsIndicators: false) {
                    PhotoSection()
                    LocationSection(profileModel: profileModel)
                    BioSection(profileModel: profileModel)
                    PhysicalInfoSection(profileModel: profileModel)
                    FitnessPreferencesSection(profileModel: profileModel, userManager: DBUserManager())
                }
                
            }
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onDisappear {
            Task {
                await saveProfile()
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func saveProfile() async {
        guard let updatedUser = profileModel.user else { return }
        do {
            try await DBUserManager.shared.updateUser(updatedUser)
        } catch {
            print("Error updating user profile: \(error)")
        }
    }
    
    private var headerSection: some View {
        HStack {
            Text("Edit Profile")
                .h1Style()
            Spacer()
        }
        .foregroundStyle(.syncBlack)
    }
}
