import SwiftUI



struct FilteredFitnessGoalView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @State private var loadedFitnessGoals: [FitnessGoal] = StandardFitnessGoal.allCases.map {
        FitnessGoal(id: $0.id, goal: $0.rawValue, emoji: $0.emoji)
    }
    
    @State private var showPayWallView: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton()
                    Spacer()
                    OnBoardingNavigationLinkSkip {
                        //                        NavigationStack {
                        FilteredFitnessLevelView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                        //                        }
                    }
                    .onTapGesture {
                        signUpModel.filteredFitnessGoals = []
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
                            ForEach(loadedFitnessGoals.sorted(by: { $0.goal < $1.goal })) { type in
                                InterestPillView(
                                    emoji: type.emoji,
                                    name: type.goal,
                                    backgroundColour: signUpModel.filteredFitnessGoals.contains(type) ? Color.syncGreen : Color.syncGrey,
                                    foregroundColour: signUpModel.filteredFitnessGoals.contains(type) ? Color.syncBlack : Color.syncWhite
                                )
                                .onTapGesture {
                                    if subscriptionModel.isSubscriptionActive {
                                        if signUpModel.filteredFitnessGoals.contains(type) && signUpModel.filteredFitnessGoals.count < 5 {
                                            signUpModel.filteredFitnessGoals.removeAll { $0 == type }
                                        } else {
                                            signUpModel.filteredFitnessGoals.append(type)
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
                    OnBoardingNavigationLink(text: "Next") {
                        //                    NavigationStack {
                        FilteredFitnessLevelView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
                        //                    }
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

