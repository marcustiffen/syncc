import SwiftUI

struct WelcomeConnectorView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    
//    @Binding var showOnBoardingView: Bool
//    @Binding var showEmailLayer: Bool
    
    @EnvironmentObject var signUpModel: SignUpModel
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .email
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .email)
                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Welcome to Syncc! Now lets go ahead and make your profile!")
            }
            .titleModifiers()
            
            Spacer()
            
            HStack {
                Spacer()
//                OnBoardingNavigationLink(text: "Next") {
//                    NameView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .name
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: nil, value: nil, onboardingStep: .name)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
