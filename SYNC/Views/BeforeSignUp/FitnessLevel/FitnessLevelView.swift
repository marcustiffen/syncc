import SwiftUI


struct FitnessLevelView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var fitnessLevel: Double = 1 // Default to 1 (Beginner)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .fitnessProfileConnector
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .fitnessProfileConnector)

                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 40)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "figure.highintensity.intervaltraining")
                Text("What Fitness Level Are you")
            }
            .titleModifiers()
            
            Slider(value: $fitnessLevel, in: 1...8, step: 1)
                .accentColor(.syncBlack)
                .animation(.easeIn, value: fitnessLevel)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Your fitness level: \(signUpModel.fitnessLevel)")
                    .foregroundStyle(.syncBlack)
                    .h2Style()
                
                Text(fitnessDescription(for: Int(fitnessLevel)))
                    .foregroundStyle(.syncGrey)
                    .bodyTextStyle()
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            HStack {
                Spacer()
//                OnBoardingNavigationLink(text: "Next") {
//                    FitnessTypeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .fitnessTypes
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "fitnessLevel", value: signUpModel.fitnessLevel, onboardingStep: .fitnessTypes)

                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .onChange(of: fitnessLevel) { oldValue, newValue in
            signUpModel.fitnessLevel = fitnessLevelName(for: Int(newValue))
        }
    }
    
    func fitnessLevelName(for level: Int) -> String {
        switch level {
        case 1: return "Beginner"
        case 2: return "Casual"
        case 3: return "Active"
        case 4: return "Intermediate"
        case 5: return "Enthusiast"
        case 6: return "Advanced"
        case 7: return "Athlete"
        case 8: return "Elite"
        default: return "Any"
        }
    }
    
    func fitnessDescription(for level: Int) -> String {
        switch level {
        case 1: return "New to exercise or returning after a long break"
        case 2: return "Light exercise 1-2 times per week"
        case 3: return "Regular exercise 2-3 times per week"
        case 4: return "Consistent training 3-4 times per week"
        case 5: return "Dedicated training 4-5 times per week"
        case 6: return "Intense training 5-6 times per week"
        case 7: return "Daily training with competitive goals"
        case 8: return "Professional or elite competitive level"
        default: return "Select your fitness level"
        }
    }
}
