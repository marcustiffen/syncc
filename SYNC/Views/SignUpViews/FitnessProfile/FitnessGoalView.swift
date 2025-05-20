import SwiftUI



struct FitnessGoalView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    
    @State private var loadedFitnessGoals: [FitnessGoal] = StandardFitnessGoal.allCases.map {
        FitnessGoal(id: $0.id, goal: $0.rawValue, emoji: $0.emoji)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton()
                    Spacer()
                    OnBoardingNavigationLinkSkip {
                        HeightView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                    .onTapGesture {
                        signUpModel.fitnessGoals = []
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
                            ForEach(loadedFitnessGoals.sorted(by: { $0.goal < $1.goal })) { type in
                                InterestPillView(
                                    emoji: type.emoji,
                                    name: type.goal,
                                    backgroundColour: signUpModel.fitnessGoals.contains(type) ? Color.syncGreen : Color.syncGrey,
                                    foregroundColour: signUpModel.fitnessGoals.contains(type) ? Color.syncBlack : Color.syncWhite
                                )
//                                .onTapGesture {
//                                    if signUpModel.fitnessGoals.contains(type) && signUpModel.fitnessGoals.count < 5 {
//                                        signUpModel.fitnessGoals.removeAll { $0 == type }
//                                    } else {
//                                        signUpModel.fitnessGoals.append(type)
//                                    }
//                                }
                                .onTapGesture {
                                    if signUpModel.fitnessGoals.contains(type) {
                                        // If already selected, remove it
                                        signUpModel.fitnessGoals.removeAll { $0 == type }
                                    } else if signUpModel.fitnessGoals.count < 5 {
                                        // If not selected and under the limit, add it
                                        signUpModel.fitnessGoals.append(type)
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
                    OnBoardingNavigationLink(text: "Next") {
                        HeightView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
    }
}
