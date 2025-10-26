import SwiftUI



struct FilteredFitnessLevelView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @State private var fitnessLevel: Double = 1 // Default to 1 (Any)
    
    @State private var showPayWallView: Bool = false
    
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                SyncBackButton {
                    withAnimation {
                        signUpModel.onboardingStep = .filteredFitnessGoals
                    }
                    Task {
                        if let uid = signUpModel.uid {
                            await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .filteredFitnessGoals)
                        }

                    }
                }
                Spacer()
                OnBoardingNavigationLinkSkip {
                    withAnimation {
                        signUpModel.onboardingStep = .blockedSex
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredFitnessLevel", value: signUpModel.filteredFitnessLevel, onboardingStep: .blockedSex)

                    }
                }
            }
            .padding(.bottom, 40)
            
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "figure.highintensity.intervaltraining")
                    Text("What fitness level would you like to see?")
                }
                .titleModifiers()
                
                if !subscriptionModel.isSubscriptionActive {
                    Text("NOTE: ")
                        .bold()
                        .h2Style()
                    
                    Text("This is a premium feature!")
                        .bodyTextStyle()
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.syncGrey)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    
                    OnBoardingButton(text: "Upgrade here") {
                        showPayWallView = true
                    }
                }
            }
            
 
            Slider(
                value: Binding<Double>(
                    get: {
                        fitnessLevel
                    },
                    set: { newValue in
                        if subscriptionModel.isSubscriptionActive {
                            fitnessLevel = newValue
                        } else {
                            showPayWallView = true
                        }
                    }
                ),
                in: 1...9,
                step: 1
            )
            .accentColor(.syncBlack)
            .animation(.easeIn, value: fitnessLevel)
            
            
            Text("Fitness level you want to see: \(signUpModel.filteredFitnessLevel)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .h2Style()
                .foregroundStyle(.syncBlack)
            
            Spacer()
            
            HStack {
                Spacer()
//                OnBoardingNavigationLink(text: "Next") {
//                    CompleteSignUpView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                }
                OnBoardingButton(text: "Next") {
                    withAnimation {
                        signUpModel.onboardingStep = .blockedSex
                    }
                    Task {
                        await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredFitnessLevel", value: signUpModel.filteredFitnessLevel, onboardingStep: .blockedSex)

                    }
                }
            }
        }
        .sheet(isPresented: $showPayWallView, content: {
            PayWallView(isPaywallPresented: $showPayWallView)
        })
        .task {
            signUpModel.filteredFitnessLevel = fitnessDescription(for: 1)
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .onChange(of: fitnessLevel) { oldValue, newValue in
            signUpModel.filteredFitnessLevel = fitnessDescription(for: Int(newValue))
        }
    }
    
    func fitnessDescription(for level: Int) -> String {
        switch level {
        case 1: return "Any"
        case 2: return "Beginner"
        case 3: return "Casual"
        case 4: return "Active"
        case 5: return "Intermediate"
        case 6: return "Enthusiast"
        case 7: return "Advanced"
        case 8: return "Athlete"
        case 9: return "Elite"
        default: return "Any"
        }
    }
}
