import Foundation
import FirebaseAuth



class PhoneAuthenticationViewModel: ObservableObject {
    static var shared = PhoneAuthenticationViewModel()
    
    @Published var mobileZoneCode = "+61"
    @Published var txtMobile = ""
    @Published var txtCode: String = ""
    @Published var verificationID: String = ""
    
    @Published var showError = false
    @Published var errorMessage: String = ""
    
    
    func sendSMS(completion: @escaping (Bool) -> Void) {
        guard !txtMobile.isEmpty else {
            errorMessage = "Please enter a phone number"
            showError = true
            completion(false)
            return
        }
        
        guard !mobileZoneCode.isEmpty else {
            errorMessage = "Please enter a valid phone number"
            showError = true
            completion(false)
            return
        }
        
        let phoneNumberRegex = #"^\d{7,15}$"#
        guard txtMobile.range(of: phoneNumberRegex, options: .regularExpression) != nil else {
            errorMessage = "Please enter a valid phone number"
            showError = true
            completion(false)
            return
        }
        
        PhoneAuthProvider.provider().verifyPhoneNumber(mobileZoneCode + txtMobile, uiDelegate: nil) { verificationId, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showError = true
                completion(false)
                return
            }
            
            if let verificationId = verificationId {
                self.verificationID = verificationId
                print("Verification ID saved in ViewModel: \(verificationId)")
                completion(true)
            } else {
                self.errorMessage = "Verification ID could not be retrieved."
                self.showError = true
                completion(false)
            }
        }
    }
    
    func verifyCode(completion: @escaping (Bool) -> Void) {
        guard !txtCode.isEmpty else {
            self.errorMessage = "Please enter a valid code"
            self.showError = true
            completion(false)
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
                completion(false)
            } else {
                self.errorMessage = "Login Successful"
                self.showError = false
                completion(true)
            }
        }
    }
}
