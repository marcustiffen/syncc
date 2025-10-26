import SwiftUI
import UIKit
import SwiftfulUI

struct FitnessTypeView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var loadedFitnessTypes: [String] = StandardFitnessType.allCases.map(\.rawValue)
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .fitnessLevel
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .fitnessLevel)

                            }
                        }
                    }
                    Spacer()
//                    OnBoardingNavigationLinkSkip {
//                        FitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingNavigationLinkSkip {
                        withAnimation {
                            signUpModel.onboardingStep = .fitnessGoals
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "fitnessTypes", value: signUpModel.fitnessTypes, onboardingStep: .fitnessGoals)

                        }
                    }
                }
                .padding(.bottom, 40)
                
                
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "figure.run")
                    Text("Choose up to 5 workout preferences")
                }
                .titleModifiers()
                
                ZStack(alignment: .bottom) {
                    DynamicGridView<String>(isSubscriptionActive: true, selectedItems: $signUpModel.fitnessTypes, showPayWallView: .constant(false), items: loadedFitnessTypes.sorted(by: { $0 < $1 })) { type in
                        InterestPillView(
                            emoji: FitnessTypeHelper.emoji(for: type),
                            name: type,
                            backgroundColour: signUpModel.fitnessTypes.contains(type) ? Color.syncGreen : Color.syncGrey,
                            foregroundColour: signUpModel.fitnessTypes.contains(type) ? Color.syncBlack : Color.syncWhite
                        )
                    }
                    .animation(.easeIn, value: signUpModel.fitnessTypes.count)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [.syncWhite.opacity(0.0), .syncWhite], startPoint: .top, endPoint: .bottom)
                        )
                        .frame(height: 20)
                        .allowsHitTesting(false)
                }
                Spacer(minLength: 70)
            }
                        
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    OnBoardingButton(text: "Next") {
                        withAnimation {
                            signUpModel.onboardingStep = .fitnessGoals
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "fitnessTypes", value: signUpModel.fitnessTypes, onboardingStep: .fitnessGoals)

                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}


