
import SwiftUI

struct FilteredSexView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var sexes = ["Male", "Female", "Both"]
    
    var body: some View {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .filteredAgeRange
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .filteredAgeRange)

                            }
                        }
                    }
                    Spacer()
//                    OnBoardingNavigationLinkSkip {
//                        FilteredMatchRadiusView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingNavigationLinkSkip {
                        withAnimation {
                            signUpModel.onboardingStep = .matchRadius
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredSex", value: signUpModel.filteredSex, onboardingStep: .matchRadius)

                        }
                    }
                }
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "person.2")
                    Text("Choose the sex(es) do you want to sync up with")
                }
                .titleModifiers()
                
                CustomSegmentPicker(options: sexes, selected: $signUpModel.filteredSex)
                
                Spacer()
                
                HStack {
                    Spacer()
//                    OnBoardingNavigationLink(text: "Next") {
//                        FilteredMatchRadiusView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingButton(text: "Next") {
                        withAnimation {
                            signUpModel.onboardingStep = .matchRadius
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredSex", value: signUpModel.filteredSex, onboardingStep: .matchRadius)

                        }
                    }
                }
            }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
