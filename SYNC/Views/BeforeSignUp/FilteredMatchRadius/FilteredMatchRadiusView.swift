
import SwiftUI

struct FilteredMatchRadiusView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .filteredSex
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .filteredSex)

                        }
                    }
                }
                Spacer()
//                OnBoardingNavigationLinkSkip {
//                    FilteredFitnessTypeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingNavigationLinkSkip {
                    withAnimation {
                        signUpModel.onboardingStep = .filteredFitnessTypes
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredMatchRadius", value: signUpModel.filteredMatchRadius, onboardingStep: .filteredFitnessTypes)

                    }
                }
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "location.north.circle")
                Text("Choose your radius")
            }
            .titleModifiers()
            
            Text("Radius: \(Int(signUpModel.filteredMatchRadius)) km")
                .h2Style()
                .foregroundStyle(.syncBlack)
            
            Slider(value: $signUpModel.filteredMatchRadius, in: 0...100, step: 1)
                .tint(.syncBlack)
            
            Spacer()
            
            HStack {
                Spacer()
//                OnBoardingNavigationLink(text: "Next") {
//                    FilteredFitnessTypeView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .filteredFitnessTypes
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredMatchRadius", value: signUpModel.filteredMatchRadius, onboardingStep: .filteredFitnessTypes)

                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}

