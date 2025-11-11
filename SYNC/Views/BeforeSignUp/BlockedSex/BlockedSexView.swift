import SwiftUI



struct BlockedSexView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @State private var showPayWallView: Bool = false
    
    @State private var sexes = ["Male", "Female", "None"]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .filteredFitnessLevel
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .filteredFitnessLevel)
                        }
                    }
                }
                Spacer()
                
                OnBoardingNavigationLinkSkip {
                    withAnimation {
                        signUpModel.onboardingStep = .complete
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "blockedSex", value: signUpModel.blockedSex, onboardingStep: .complete)
                    }
                }
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "person.2")
                Text("Choose the sex(es) do you NOT want to sync up with")
            }
            .titleModifiers()
            
            CustomSegmentPicker(options: sexes, selected: $signUpModel.blockedSex)
            
            Spacer()
            
            HStack {
                Spacer()
                //                    OnBoardingNavigationLink(text: "Next") {
                //                        FilteredMatchRadiusView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                //                    }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .complete
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "blockedSex", value: signUpModel.blockedSex, onboardingStep: .complete)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
