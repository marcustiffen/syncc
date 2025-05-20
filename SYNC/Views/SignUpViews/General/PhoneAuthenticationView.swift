import FirebaseAuth
import SwiftUI


class PhoneAuthenticationViewModel: ObservableObject {
    static var shared = PhoneAuthenticationViewModel()
    
    @Published var mobileZoneCode = "+44"
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


struct PhoneAuthenticationView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
    @Binding var showEmailLayer: Bool
    @Binding var showOnBoardingView: Bool
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var signUpModel: SignUpModel
    @State private var showVerifyButton = false
    @State private var smsCode: String = ""
    @StateObject var phoneAuthViewModel = PhoneAuthenticationViewModel()
    
//    @State private var showEmailView = false
    
    @State private var showChangeNumberButton = false
    
    @State private var verificationDigits: [String] = Array(repeating: "", count: 6)
    
    @State private var selectedCountry = Country(code: "+44", name: "United Kingdom", flag: "🇬🇧")
    
    @State var countries: [Country] = [
//        Country(code: "+93", name: "Afghanistan", flag: "🇦🇫"),
//        Country(code: "+213", name: "Algeria", flag: "🇩🇿"),
        Country(code: "+61", name: "Australia", flag: "🇦🇺"),
//        Country(code: "+55", name: "Brazil", flag: "🇧🇷"),
//        Country(code: "+1", name: "Canada", flag: "🇨🇦"),
//        Country(code: "+86", name: "China", flag: "🇨🇳"),
//        Country(code: "+33", name: "France", flag: "🇫🇷"),
//        Country(code: "+49", name: "Germany", flag: "🇩🇪"),
//        Country(code: "+91", name: "India", flag: "🇮🇳"),
//        Country(code: "+62", name: "Indonesia", flag: "🇮🇩"),
//        Country(code: "+81", name: "Japan", flag: "🇯🇵"),
//        Country(code: "+254", name: "Kenya", flag: "🇰🇪"),
//        Country(code: "+60", name: "Malaysia", flag: "🇲🇾"),
//        Country(code: "+234", name: "Nigeria", flag: "🇳🇬"),
//        Country(code: "+47", name: "Norway", flag: "🇳🇴"),
//        Country(code: "+92", name: "Pakistan", flag: "🇵🇰"),
//        Country(code: "+63", name: "Philippines", flag: "🇵🇭"),
//        Country(code: "+7", name: "Russia", flag: "🇷🇺"),
//        Country(code: "+65", name: "Singapore", flag: "🇸🇬"),
//        Country(code: "+27", name: "South Africa", flag: "🇿🇦"),
//        Country(code: "+34", name: "Spain", flag: "🇪🇸"),
        Country(code: "+44", name: "United Kingdom", flag: "🇬🇧")
//        Country(code: "+1", name: "United States", flag: "🇺🇸"),
//        Country(code: "+84", name: "Vietnam", flag: "🇻🇳")
    ]
    
    
    var body: some View {
//            ZStack {
                VStack(spacing: 20) {
                    HStack {
                        SyncBackButton()
                        Spacer()
                    }
                    .padding(.bottom, 40)
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "phone")
                        Text(showVerifyButton ? "Enter the verification code" : "Enter your phone number below.")
                    }
                    .titleModifiers()
                    
                    // Phone Number Input - Only editable when not in verification mode
                    if !showVerifyButton {
                        inputField(
                            text: $phoneAuthViewModel.txtMobile,
                            placeholder: "",
                            icon: "phone", isCodeField: false
                        )
                        
                    } else {
                        // Show phone number as non-editable text when in verification mode
                        VStack(alignment: .leading) {
                            Text("Phone Number")
                                .h2Style()
                                .foregroundColor(.syncGrey)
                            HStack {
                                Text("\(phoneAuthViewModel.mobileZoneCode + phoneAuthViewModel.txtMobile)")
                                    .h2Style()
                                    .font(.system(size: 18))
                                    .foregroundColor(.syncGrey)
                                Spacer()
                                Button(action: {
                                    // Reset to phone number entry mode
                                    withAnimation {
                                        showVerifyButton = false
                                        showChangeNumberButton = false
                                        phoneAuthViewModel.txtCode = ""
                                    }
                                }) {
                                    Text("Change")
                                        .h2Style()
                                        .foregroundStyle(.syncBlack)
                                        .padding(5)
                                        .background(
                                            Rectangle()
                                                .clipShape(.rect(cornerRadius: 10))
                                                .foregroundStyle(.syncGreen)
                                        )
                                }
                            }
                            .padding(.vertical, 5)
                            
                            Divider()
                        }
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Verification Code")
                                .h2Style()
                                .foregroundColor(.syncGrey)
                            
                            OTPFieldView(numberOfFields: 6, otp: $phoneAuthViewModel.txtCode)
                            
                        }
                        .frame(maxWidth: .infinity)
                    }
                    Spacer()
                    
                    HStack {
                        Spacer()
                        if showVerifyButton {
                            HStack(spacing: 15) {
                                OnBoardingButton(text: "Verify Code") {
                                    phoneAuthViewModel.verifyCode { success in
                                        if success {
                                            signUpModel.phoneNumber = phoneAuthViewModel.txtMobile
                                            withAnimation {
                                                showEmailLayer = true
                                            }
                                        }
                                    }
                                }
                            }
                            .transition(.opacity)
                        } else {
                            OnBoardingButton(text: "Submit Number") {
                                phoneAuthViewModel.sendSMS { success in
                                    if success {
                                        withAnimation {
                                            showVerifyButton = true
                                            showChangeNumberButton = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Fixed position buttons at bottom right
//                VStack {
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        if showVerifyButton {
//                            HStack(spacing: 15) {
//                                OnBoardingButton(text: "Verify Code") {
//                                    phoneAuthViewModel.verifyCode { success in
//                                        if success {
//                                            signUpModel.phoneNumber = phoneAuthViewModel.txtMobile
//                                            withAnimation {
//                                                showEmailLayer = true
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            .transition(.opacity)
//                        } else {
//                            OnBoardingButton(text: "Submit Number") {
//                                phoneAuthViewModel.sendSMS { success in
//                                    if success {
//                                        withAnimation {
//                                            showVerifyButton = true
//                                            showChangeNumberButton = true
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
            .navigationBarBackButtonHidden(true)
            .onBoardingBackground()
            .alert(isPresented: $phoneAuthViewModel.showError) {
                Alert(
                    title: Text("Syncc"),
                    message: Text(phoneAuthViewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
//    }
    
    @ViewBuilder
    private func inputField(text: Binding<String>, placeholder: String, icon: String, isCodeField: Bool) -> some View {
        HStack(alignment: .bottom) {
            VStack {
                if !isCodeField {
                    Menu {
                        ForEach(countries.sorted(by: { $0.name > $1.name }), id: \.self) { country in
                            Button {
                                selectedCountry = country
                                phoneAuthViewModel.mobileZoneCode = selectedCountry.code
                            } label: {
                                HStack {
                                    Text("\(country.flag) \(country.name) (\(country.code))")
                                        .foregroundStyle(.syncGrey)
                                    
                                    if selectedCountry == country {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .h2Style()
                            }
                        }
                    } label: {
                        Text("\(selectedCountry.flag) \(selectedCountry.code)")
                            .lineLimit(1)
                            .h1Style()
                            .padding(.trailing, 8)
//                            .padding(.bottom, 3)
                    }
                    .tint(.syncBlack)
                    
                    Rectangle()
                        .fill(.syncGrey)
                        .frame(height: 2)
                }
            }
            // Increase frame width to accommodate full country code display
            .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            VStack(spacing: 0) {
                HStack(spacing: 20) {
                    TextField("", text: text, prompt: Text(placeholder).font(.h2).foregroundStyle(.syncGrey))
                        .keyboardType(.numberPad)
                        .h1Style()
                        .foregroundStyle(.syncBlack)
                        .frame(height: 50)
                }
                .padding(.bottom, 3)
                
                Rectangle()
                    .fill(.syncGrey)
                    .frame(height: 2)
            }
        }
        .frame(height: 50)
    }
}
