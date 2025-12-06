import SwiftUI




struct ConfirmDeletionView: View {
    @Binding var showCreateOrSignInView: Bool
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var navigateToCreateOrSignInView = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                SyncBackButton { dismiss() }
                Spacer()
            }
            .padding(.bottom, 20)
            
            Text("Hang on! We need to double-check it's you before we go ahead with deleting your account.")
                .foregroundStyle(.syncBlack)
                .h2Style()
                .padding(.bottom, 20)
            
            CustomOnBoardingTextField(placeholder: "Email", image: "envelope.fill", text: $email)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
            
            CustomOnBoardingSecureField(placeholder: "Password", image: "lock.fill", text: $password)
                
            Button {
                // Validate inputs first
                guard !email.isEmpty, !password.isEmpty else {
                    errorMessage = "Please enter both email and password"
                    showError = true
                    return
                }
                
                isLoading = true
                Task {
                    await confirmDeletion(email: email, password: password)
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isLoading ? "Deleting..." : "Delete")
                        .h2Style()
                        .foregroundStyle(.white)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.red)
                )
            }
            .disabled(isLoading)
            
            Spacer()
            
            NavigationLink {
                ForgotPasswordView()
            } label: {
                Text("Forgot your password?")
                    .bodyTextStyle()
                    .bold()
            }
            
            Spacer()
        }
//        .navigationDestination(isPresented: $navigateToCreateOrSignInView, destination: {
//            CreateOrSignInView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: .constant(false), loadingViewFinishedLoading: .constant(false), bannedMessage: "")
//        })
        .padding(.horizontal, 10)
        .background(Color.white.ignoresSafeArea())
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    @MainActor
    func confirmDeletion(email: String, password: String) async {
        defer { isLoading = false }
        
        guard let userId = profileModel.user?.uid else {
            errorMessage = "User not found"
            showError = true
            return
        }
        
        do {
            try await profileModel.deleteUser(uid: userId, email: email, password: password)
            // Only navigate if deletion was successful
//            navigateToCreateOrSignInView = true
            showCreateOrSignInView = true
        } catch {
            // Handle the error properly
            print("Deletion error: \(error)")
            
            // Check if it's a specific type of error
            if let profileError = error as? ProfileModelError {
                switch profileError {
                case .invalidCredentials:
                    errorMessage = "Invalid email or password"
                case .userNotFound:
                    errorMessage = "User not found"
                case .networkError:
                    errorMessage = "Network error. Please try again."
                default:
                    errorMessage = "An unexpected error occurred"
                }
            } else {
                // Handle other error types
                errorMessage = error.localizedDescription
            }
            
            showError = true
        }
    }
}

// If you don't have this enum, you might need to add it to your ProfileModel
enum ProfileModelError: Error, LocalizedError {
    case invalidCredentials
    case userNotFound
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "User not found"
        case .networkError:
            return "Network error occurred"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
