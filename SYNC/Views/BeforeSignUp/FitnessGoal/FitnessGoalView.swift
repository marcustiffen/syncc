import SwiftUI



struct FitnessGoalView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var loadedFitnessGoals: [String] = StandardFitnessGoal.allCases.map(\.rawValue)
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .fitnessTypes
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .fitnessTypes)

                            }
                        }
                    }
                    Spacer()
//                    OnBoardingNavigationLinkSkip {
//                        HeightView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingNavigationLinkSkip {
                        withAnimation {
                            signUpModel.onboardingStep = .height
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "fitnessGoals", value: signUpModel.fitnessGoals, onboardingStep: .height)

                        }
                    }
                }
                .padding(.bottom, 40)
                
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "dumbbell")
                    Text("Choose up to 5 fitness goals!")
                }
                .titleModifiers()
                
                ZStack(alignment: .bottom) {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 10) {
                            ForEach(loadedFitnessGoals.sorted(by: { $0 < $1 })) { goal in
                                InterestPillView(
                                    emoji: FitnessGoalHelper.emoji(for: goal),
                                    name: goal,
                                    backgroundColour: signUpModel.fitnessGoals.contains(goal) ? Color.syncGreen : Color.syncGrey,
                                    foregroundColour: signUpModel.fitnessGoals.contains(goal) ? Color.syncBlack : Color.syncWhite
                                )
//                                .onTapGesture {
//                                    if signUpModel.fitnessGoals.contains(type) && signUpModel.fitnessGoals.count < 5 {
//                                        signUpModel.fitnessGoals.removeAll { $0 == type }
//                                    } else {
//                                        signUpModel.fitnessGoals.append(type)
//                                    }
//                                }
                                .onTapGesture {
                                    if signUpModel.fitnessGoals.contains(goal) {
                                        // If already selected, remove it
                                        signUpModel.fitnessGoals.removeAll { $0 == goal }
                                    } else if signUpModel.fitnessGoals.count < 5 {
                                        // If not selected and under the limit, add it
                                        signUpModel.fitnessGoals.append(goal)
                                    }
                                }

                            }
                        }
                        .animation(.easeIn, value: signUpModel.fitnessGoals.count)
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
//                        HeightView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingButton(text: "Next") {
                        withAnimation {
                            signUpModel.onboardingStep = .height
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "fitnessGoals", value: signUpModel.fitnessGoals, onboardingStep: .height)

                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
