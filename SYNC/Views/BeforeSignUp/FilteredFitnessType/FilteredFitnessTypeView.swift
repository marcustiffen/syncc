import SwiftUI



struct FilteredFitnessTypeView: View {
    @Binding var showCreateOrSignInView: Bool
    @Binding var isLoading: Bool
    @Binding var loadingViewFinishedLoading: Bool
    @EnvironmentObject var signUpModel: SignUpModel
    @EnvironmentObject var subscriptionModel: SubscriptionModel
    
    @State private var loadedFitnessTypes: [String] = StandardFitnessType.allCases.map(\.rawValue)
    
    @State private var showPayWallView = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                HStack {
                    SyncBackButton {
                        withAnimation {
                            signUpModel.onboardingStep = .matchRadius
                        }
                        Task {
                            if let uid = signUpModel.uid {
                                await signUpModel.saveOnboardingStep(uid: uid, onboardingStep: .matchRadius)

                            }
                        }
                    }
                    Spacer()
//                    OnBoardingNavigationLinkSkip {
//                        FilteredFitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingNavigationLinkSkip {
                        withAnimation {
                            signUpModel.onboardingStep = .filteredFitnessGoals
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredFitnessTypes", value: signUpModel.filteredFitnessTypes, onboardingStep: .filteredFitnessGoals)

                        }
                    }
                }
                .padding(.bottom, 40)
                
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "sportscourt")
                        Text("Filter from up to 5 workout preferences!")
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
                    // Use subscription model's active status for FilteredFitnessTypeView
                    DynamicGridView<String>(
                        isSubscriptionActive: subscriptionModel.isSubscriptionActive,
                        selectedItems: $signUpModel.filteredFitnessTypes,
                        showPayWallView: $showPayWallView,
                        items: loadedFitnessTypes.sorted(by: { $0 < $1 })
                    ) { type in
                        InterestPillView(
                            emoji: FitnessTypeHelper.emoji(for: type),
                            name: type,
                            backgroundColour: signUpModel.filteredFitnessTypes.contains(type) ? Color.syncGreen : Color.syncGrey,
                            foregroundColour: signUpModel.filteredFitnessTypes.contains(type) ? Color.syncBlack : Color.syncWhite
                        )
                    }
//                    DynamicGridView(
//                        isSubscriptionActive: subscriptionModel.isSubscriptionActive,
//                        selectedItems: $signUpModel.filteredFitnessTypes,
//                        showPayWallView: $showPayWallView,
//                        items: loadedFitnessTypes.sorted(by: { $0.name < $1.name }),
//                        itemContent: { type in
//                        InterestPillView(
//                            emoji: type.emoji,
//                            name: type.name,
//                            backgroundColour: signUpModel.filteredFitnessTypes.contains(type) ? Color.syncGreen : Color.syncGrey,
//                            foregroundColour: signUpModel.filteredFitnessTypes.contains(type) ? Color.syncBlack : Color.syncWhite
//                        )
//                    })
                    .animation(.easeIn, value: signUpModel.filteredFitnessTypes.count)
                    
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
//                        FilteredFitnessGoalView(showCreateOrSignInView: $showCreateOrSignInView, isLoading: $isLoading, loadingViewFinishedLoading: $loadingViewFinishedLoading)
//                    }
                    OnBoardingButton(text: "Next") {
                        withAnimation {
                            signUpModel.onboardingStep = .filteredFitnessGoals
                        }
                        Task {
                            await signUpModel.saveProgress(uid: signUpModel.uid ?? "", key: "filteredFitnessTypes", value: signUpModel.filteredFitnessTypes, onboardingStep: .filteredFitnessGoals)

                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onBoardingBackground()
        .sheet(isPresented: $showPayWallView) {
            PayWallView(isPaywallPresented: $showPayWallView)
        }
    }
}

