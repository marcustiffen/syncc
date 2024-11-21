import SwiftUI
import FirebaseAuth

class PhoneAuthenticationViewModel: ObservableObject {
    static var shared = PhoneAuthenticationViewModel()
    
    @Published var txtMobile = ""
    @Published var txtMobileCode = ""
    @Published var showOTP = false
    
    @Published var txtCode: String = ""
    @Published var verificationID: String = ""
    
    @Published var showError = false
    @Published var errorMessage: String = ""
    
    
    func submitMobileNumber() {
        sendSMS()
    }
    
    
    //    func sendSMS() {
    //        PhoneAuthProvider.provider().verifyPhoneNumber("+44" + txtMobile, uiDelegate: nil) { verificationId, error in
    //            if let error = error {
    //                self.errorMessage = error.localizedDescription
    //                self.showError = true
    //                return
    //            } else {
    //                self.verificationID = verificationId ?? ""
    //            }
    //        }
    //    }
    
    func sendSMS() {
        PhoneAuthProvider.provider().verifyPhoneNumber("+44" + txtMobile, uiDelegate: nil) { verificationId, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showError = true
                return
            }
            
            if let verificationId = verificationId {
                self.verificationID = verificationId
                print("Verification ID saved in ViewModel: \(verificationId)")  // Debugging line
            } else {
                self.errorMessage = "Verification ID could not be retrieved."
                self.showError = true
            }
        }
    }
    
    func verifyCode() {
        guard !txtCode.isEmpty else {
            self.errorMessage = "Please enter a valid code"
            self.showError = true
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: txtCode
        )
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("Error signing in: \(error.localizedDescription)")
                self.showError = true
            } else {
                self.errorMessage = "Login Successful"
                self.showError = true
            }
        }
    }
}



struct AuthLayerView: View {
    @Binding var showSignInView: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var showVerifyButton = false
    @State private var smsCode: String = ""
    
    @State private var showAuthLayer: Bool = false
    
    @StateObject var phoneAuthViewModel = PhoneAuthenticationViewModel()
    
    var body: some View {
        VStack {
            TextField("Enter Phone Number", text: $phoneAuthViewModel.txtMobile)
            
            Button {
                phoneAuthViewModel.submitMobileNumber()
                showVerifyButton = true
            } label: {
                Text("Submit number")
            }
            
            if showVerifyButton {
                VStack(spacing: 5) {
                    TextField("SMS Code", text: $phoneAuthViewModel.txtCode)
                    Button {
                        phoneAuthViewModel.verifyCode()
                        showAuthLayer = false
                    } label: {
                        Text("Sign In")
                    }
                }
            }
            
            
        }
        .alert(isPresented: $phoneAuthViewModel.showError) {
            Alert(title: Text("SYNC"), message: Text(phoneAuthViewModel.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}

