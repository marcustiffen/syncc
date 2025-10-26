import SwiftUI
import FirebaseAuth



struct PhoneAuthenticationView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var signUpModel: SignUpModel
    @State private var showVerifyButton = false
    @State private var smsCode: String = ""
    @StateObject var phoneAuthViewModel = PhoneAuthenticationViewModel()
    
    @State private var showChangeNumberButton = false
    
    @State private var verificationDigits: [String] = Array(repeating: "", count: 6)
    
    @State private var selectedCountry = Country(code: "+44", name: "United Kingdom", flag: "🇬🇧")
    
    @State var countries: [Country] = [
        Country(code: "+93", name: "Afghanistan", flag: "🇦🇫"),
        Country(code: "+213", name: "Algeria", flag: "🇩🇿"),
        Country(code: "+61", name: "Australia", flag: "🇦🇺"),
        Country(code: "+55", name: "Brazil", flag: "🇧🇷"),
        Country(code: "+1", name: "Canada", flag: "🇨🇦"),
        Country(code: "+86", name: "China", flag: "🇨🇳"),
        Country(code: "+33", name: "France", flag: "🇫🇷"),
        Country(code: "+49", name: "Germany", flag: "🇩🇪"),
        Country(code: "+91", name: "India", flag: "🇮🇳"),
        Country(code: "+62", name: "Indonesia", flag: "🇮🇩"),
        Country(code: "+81", name: "Japan", flag: "🇯🇵"),
        Country(code: "+254", name: "Kenya", flag: "🇰🇪"),
        Country(code: "+60", name: "Malaysia", flag: "🇲🇾"),
        Country(code: "+234", name: "Nigeria", flag: "🇳🇬"),
        Country(code: "+47", name: "Norway", flag: "🇳🇴"),
        Country(code: "+92", name: "Pakistan", flag: "🇵🇰"),
        Country(code: "+63", name: "Philippines", flag: "🇵🇭"),
        Country(code: "+7", name: "Russia", flag: "🇷🇺"),
        Country(code: "+65", name: "Singapore", flag: "🇸🇬"),
        Country(code: "+27", name: "South Africa", flag: "🇿🇦"),
        Country(code: "+34", name: "Spain", flag: "🇪🇸"),
        Country(code: "+44", name: "United Kingdom", flag: "🇬🇧"),
        Country(code: "+1", name: "United States", flag: "🇺🇸"),
        Country(code: "+84", name: "Vietnam", flag: "🇻🇳")
    ]
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    dismiss()
                }
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
//                        OnBoardingButton(text: "Verify Code") {
//                            phoneAuthViewModel.verifyCode { success in
//                                if success {
//                                    signUpModel.phoneNumber = phoneAuthViewModel.txtMobile
//                                    withAnimation {
////                                      showEmailLayer = true
//                                        signUpModel.onboardingStep = .email
//                                        Task {
//                                            await signUpModel.updateUserProgress(uid: <#String#>, onboardingStep: signUpModel.onboardingStep, dbKey: "phoneNumber", dbValue: phoneAuthViewModel.mobileZoneCode + phoneAuthViewModel.txtMobile)
//                                        }
//                                    }
//                                }
//                            }
//                        }
                        OnBoardingButton(text: "Verify Code") {
                            phoneAuthViewModel.verifyCode { success in
                                if success {
                                    signUpModel.phoneNumber = phoneAuthViewModel.txtMobile
                                    Task {
                                        
                                        guard let currentUser = Auth.auth().currentUser else { return }
                                        signUpModel.uid = currentUser.uid
                                        withAnimation {
                                            signUpModel.onboardingStep = .email
                                        }
                                        await signUpModel.saveProgress(uid: currentUser.uid, key: "uid", value: currentUser.uid, onboardingStep: .email)
                                        await signUpModel.saveProgress(uid: currentUser.uid, key: "phoneNumber", value: phoneAuthViewModel.mobileZoneCode + phoneAuthViewModel.txtMobile, onboardingStep: nil)
                                        await signUpModel.saveProgress(uid: signUpModel.uid!, key: "isBanned", value: false, onboardingStep: nil)
                                        await signUpModel.saveProgress(uid: signUpModel.uid!, key: "dailyLikes", value: 3, onboardingStep: nil)
                                        await signUpModel.saveProgress(uid: signUpModel.uid!, key: "lastLikeReset", value: Date(), onboardingStep: nil)
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
    

    @ViewBuilder
    private func inputField(text: Binding<String>, placeholder: String, icon: String, isCodeField: Bool) -> some View {
        HStack(alignment: .bottom) {
            VStack {
                if !isCodeField {
                    Menu {
                        ForEach(countries.sorted(by: { $0.name < $1.name }), id: \.self) { country in
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
