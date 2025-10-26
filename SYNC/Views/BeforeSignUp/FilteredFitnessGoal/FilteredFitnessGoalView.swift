import SwiftUI



struct FilteredFitnessGoalView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @State private var loadedFitnessGoals: [String] = StandardFitnessGoal.allCases.map(\.rawValue)
    
    @State private var showPayWallView: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .filteredFitnessTypes
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .filteredFitnessTypes)

                            }
                        }
                    }
                    Spacer()
//                    OnBoardingNavigationLinkSkip {
//                        FilteredFitnessLevelView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingNavigationLinkSkip {
                        withAnimation {
                            signUpModel.onboardingStep = .filteredFitnessLevel
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredFitnessGoals", value: signUpModel.filteredFitnessGoals, onboardingStep: .filteredFitnessLevel)

                        }
                    }
                }
                .padding(.bottom, 40)
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "figure.2.arms.open")
                        Text("Filter from up to 5 fitness goals")
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
                            
                            OnBoardingButton(text: "Upgrade to Premium") {
                                showPayWallView = true
                            }
                        }
                    
                }
                
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(loadedFitnessGoals.sorted(by: { $0 < $1 })) { goal in
                                InterestPillView(
                                    emoji: FitnessGoalHelper.emoji(for: goal),
                                    name: goal,
                                    backgroundColour: signUpModel.filteredFitnessGoals.contains(goal) ? Color.syncGreen : Color.syncGrey,
                                    foregroundColour: signUpModel.filteredFitnessGoals.contains(goal) ? Color.syncBlack : Color.syncWhite
                                )
                                .onTapGesture {
                                    if subscriptionModel.isSubscriptionActive {
                                        if signUpModel.filteredFitnessGoals.contains(goal) && signUpModel.filteredFitnessGoals.count < 5 {
                                            signUpModel.filteredFitnessGoals.removeAll { $0 == goal }
                                        } else {
                                            signUpModel.filteredFitnessGoals.append(goal)
                                        }
                                    } else {
                                        showPayWallView = true
                                    }
                                }
                                
                            }
                        }
                        .animation(.easeIn, value: signUpModel.filteredFitnessGoals.count)
                    }
                    
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
//                    OnBoardingNavigationLink(text: "Next") {
//                        FilteredFitnessLevelView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingButton(text: "Next") {
                        withAnimation {
                            signUpModel.onboardingStep = .filteredFitnessLevel
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredFitnessGoals", value: signUpModel.filteredFitnessGoals, onboardingStep: .filteredFitnessLevel)

                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showPayWallView, content: {
            PayWallView(isPaywallPresented: $showPayWallView)
        })
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}

