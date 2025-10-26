import SwiftUI


struct AgeView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var showAlert = false
    
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .name
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .name)
                            }

                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 40)
                                

                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "birthday.cake")
                        Text("When's your birthday?")
                    }
                    .titleModifiers()
                    
                    Text("NOTE: ")
                        .bold()
                        .h2Style()
                    
                    Text("Your age: \(ageCalulator(dateOfBirth: signUpModel.dateOfBirth) ?? 18) cannot be changed later on!")
                        .bodyTextStyle()
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.syncGrey)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                }
                
                
                HingeDatePicker(selectedDate: $signUpModel.dateOfBirth)
                    .padding(.horizontal, 10)
                
                Spacer()
                HStack {
                    Spacer()
                    OnBoardingButton(text: "Next") {
                        withAnimation {
                            signUpModel.onboardingStep = .sex
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "dateOfBirth", value: signUpModel.dateOfBirth, onboardingStep: .sex)
                        }

                    }
                }
            }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
    
    func ageCalulator(dateOfBirth: Date) -> Int? {
        let calendar = Calendar.current
        let now = Date()
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: now)
        return ageComponents.year
    }
}




