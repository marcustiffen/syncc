import SwiftUI



struct ConfirmDeletionView: View {
    @Binding var showCreateOrSignInView: Bool
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var showError = false
    @State private var navigateToCreateOrSignInView = false
    
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                SyncBackButton()
                Spacer()
            }
            .padding(.bottom, 20)
            
            Text("Hang on! We need to double-check it’s you before we go ahead with deleting your account.")
                .foregroundStyle(.syncBlack)
                .h2Style()
                .padding(.bottom, 20)
            
            
            CustomOnBoardingTextField(placeholder: "Email", image: "envelope.fill", text: $email)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            
            CustomOnBoardingSecureField(placeholder: "Password", image: "lock.fill", text: $password)
                
            
            Button {
                Task {
                    try await confirmDeletion(email: email, password: password)
                }
            } label: {
                Text("Delete")
                    .h2Style()
                    .foregroundStyle(.white)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(.red)
                    )
            }
            
            Spacer()
        }
        .navigationDestination(isPresented: $navigateToCreateOrSignInView, destination: {
            CreateOrSignInView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: .constant(false), loadingViewFinishedLoading: .constant(false), bannedMessage: "")
        })
        .padding(.horizontal, 10)
        .background(Color.white.ignoresSafeArea())
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text("Invalid email or password"), dismissButton: .default(Text("OK")))
        }
    }
    
    func confirmDeletion(email: String, password: String) async throws {
        Task {
            do {
                try await profileModel.deleteUser(uid: profileModel.user?.uid ?? "", email: email, password: password)
                navigateToCreateOrSignInView = true
                showCreateOrSignInView = true
            } catch {
                showError = true
            }
        }
    }
}
