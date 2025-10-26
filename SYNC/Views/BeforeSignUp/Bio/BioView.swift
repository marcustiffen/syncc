import SwiftUI


struct BioView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
        
    var body: some View {
            VStack(spacing: 40) {
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .location
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .location)
                            }

                        }
                    }
                    Spacer()
                    OnBoardingNavigationLinkSkip {
                        withAnimation {
                            signUpModel.onboardingStep = .images
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "bio", value: "", onboardingStep: .images)

                        }
                    }
                }
                .padding(.bottom, 40)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "book")
                    Text("Enter your bio")
                }
                .titleModifiers()
                
                CustomOnBoardingTextEditor(text: $signUpModel.bio, placeholder: "Start typing here...")
                
                Spacer(minLength: 70)
                
                HStack {
                    Spacer()
//                    OnBoardingNavigationLink(text: "Next") {
//                            ImageSelectorView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingButton(text: "Next") {
                        withAnimation {
                            signUpModel.onboardingStep = .images
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "bio", value: signUpModel.bio, onboardingStep: .images)

                        }
                    }
                }
            }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
