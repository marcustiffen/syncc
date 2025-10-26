import SwiftUI

struct FiltersConnectorView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .weight
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .weight)

                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Now onto your filters!")
            }
            .titleModifiers()
            
            Spacer()
            
            HStack {
                Spacer()
//                OnBoardingNavigationLink(text: "Next") {
//                    FilteredAgeRangeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .filteredAgeRange
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: nil, value: nil, onboardingStep: .filteredAgeRange)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
