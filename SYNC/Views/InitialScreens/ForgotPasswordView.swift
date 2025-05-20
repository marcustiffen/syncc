import SwiftUI


struct ForgotPasswordView: View {
    @State private var email = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 40) {
            HStack {
                SyncBackButton()
                Spacer()
            }
            
            Text("Input your email to reset your password")
                .titleModifiers()
            
            Spacer()

            CustomOnBoardingTextField(placeholder: "Enter your email", text: $email)

            Button {
                Task {
                    await resetPassword()
                }
            } label: {
                Text("Send password reset e-mail")
                    .foregroundStyle(.syncBlack)
                    .h2Style()
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
            }
            .background(
                Rectangle()
                    .clipShape(.rect(cornerRadius: 10))
                    .foregroundStyle(.syncGreen)
            )
            
            Spacer()
        }
        .onBoardingBackground()
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Password Reset"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func resetPassword() async {
        do {
            try await AuthenticationManager.shared.sendPasswordResetEmail(to: email)
            alertMessage = "A password reset email has been sent to \(email). Please check your inbox."
        } catch {
            alertMessage = "Failed to send reset email: \(error.localizedDescription)"
        }
        showAlert = true
    }
}
