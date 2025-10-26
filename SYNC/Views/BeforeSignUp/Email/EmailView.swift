import SwiftUI



struct EmailView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
//    @Binding var showEmailLayer: Bool
//    @Binding var showOnBoardingView: Bool
    
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isEmailValid = true
    @State private var isPasswordValid = true
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var signUpModel: SignUpModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .phone)
                            withAnimation {
                                signUpModel.onboardingStep = .phone
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "envelope")
                Text("Enter an email and password")
            }
            .titleModifiers()
            
            VStack(alignment: .leading, spacing: 5) {
                CustomOnBoardingTextField(placeholder: "Email", image: "envelope.fill", text: $signUpModel.email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .onChange(of: signUpModel.email) { _, newValue in
                        isEmailValid = isValidEmail(newValue)
                    }
                
                if !isEmailValid && !signUpModel.email.isEmpty {
                    Text("Please enter a valid email address")
                        .bodyTextStyle()
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                CustomOnBoardingSecureField(placeholder: "Password", image: "lock.fill", text: $signUpModel.password)
                    .onChange(of: signUpModel.password) { _, newValue in
                        isPasswordValid = isValidPassword(newValue)
                    }
                
                if !isPasswordValid && !signUpModel.password.isEmpty {
                    Text("Password must be at least 8 characters with uppercase, lowercase, number, and special character")
                        .bodyTextStyle()
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                OnBoardingButton(text: "Next") {
                    if canProceed() {
                        signUpModel.linkEmailToPhoneCredential { success, errorMessage in
                            if success {
                                print("Email linked successfully!")
                                withAnimation {
                                    signUpModel.onboardingStep = .welcomeConnector
                                }
                                Task {
                                    await signUpModel.saveProgress(uid: signUpModel.uid!, key: "email", value: signUpModel.email, onboardingStep: .welcomeConnector)
                                }

                            } else {
                                showAlert = true
                                print("Failed to link email: \(errorMessage ?? "Unknown error")")
                            }
                        }
                    } else {
                        showAlert = true
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    private func canProceed() -> Bool {
        return isValidEmail(signUpModel.email) && isValidPassword(signUpModel.password) &&
        !signUpModel.email.isEmpty && !signUpModel.password.isEmpty
    }
    
    private func validateInputs() -> Bool {
        // Validate email
        if signUpModel.email == "" {
            alertMessage = "Please enter an email address."
            return false
        }
        
        if signUpModel.password == "" {
            alertMessage = "Please enter a password."
            return false
        }
        
        if !isValidEmail(signUpModel.email) {
            alertMessage = "Please enter a valid email address."
            return false
        }
        
        // Validate password
        if !isValidPassword(signUpModel.password) {
            alertMessage = """
            Password must be at least 8 characters long,
            contain an uppercase letter, a lowercase letter,
            a number, and a special character.
            """
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}





