import SwiftUI

struct HeightView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .fitnessGoals
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .fitnessGoals)

                        }
                    }
                }
                Spacer()
//                OnBoardingNavigationLinkSkip {
//                    WeightView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingNavigationLinkSkip {
                    withAnimation {
                        signUpModel.onboardingStep = .weight
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "height", value: signUpModel.height, onboardingStep: .weight)

                    }
                }
            }
            .padding(.bottom, 40)
            
            
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "ruler")
                    .rotationEffect(.degrees(90))
                Text("How tall are you?")
            }
            .titleModifiers()
            
            Picker("Choose Height", selection: $signUpModel.height) {
                ForEach(0...210, id: \.self) { height in
                    Text("\(height) cm")
                        .h2Style()
                        .foregroundStyle(.syncBlack)
                }
            }
            .scrollContentBackground(.hidden)
            .pickerStyle(.wheel)
            
            Spacer()
            
            HStack {
                Spacer()
                
//                OnBoardingNavigationLink(text: "Next") {
//                    WeightView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .weight
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "height", value: signUpModel.height, onboardingStep: .weight)

                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
